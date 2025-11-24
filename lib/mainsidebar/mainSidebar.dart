import 'dart:convert';
import 'package:aljeflutterapp/Inbound/BayanExpense.dart';
import 'package:aljeflutterapp/Inbound/inboundinitiator.dart';
import 'package:aljeflutterapp/Reports/Inter_ORG_Report/Inter_ORG_mainpage.dart';
// import 'package:aljeflutterapp/Reports/LoadIntruckpage.dart';
import 'package:aljeflutterapp/Reports/PickScanViewReport.dart';
import 'package:aljeflutterapp/Reports/RI_Report_page.dart';
import 'package:aljeflutterapp/Reports/ReturnInvoice.dart';
import 'package:aljeflutterapp/Reports/ViewDispatch.dart';
import 'package:aljeflutterapp/Reports/ViewPicking.dart';
import 'package:aljeflutterapp/Reports/ShippingViewReport.dart';
import 'package:aljeflutterapp/Reports/invoicedetailsreport.dart';
import 'package:aljeflutterapp/cacheupdate.date/services/version_service.dart';
import 'package:aljeflutterapp/dispatch/Commersial_Form.dart';
import 'package:aljeflutterapp/dispatch/Completed_dispatch/Completed_dispatch_page.dart';
import 'package:aljeflutterapp/dispatch/Load_Intruck.dart/Load_Intruck_page.dart';
import 'package:aljeflutterapp/dispatch/Load_live_stage/live_staging_page.dart';
import 'package:aljeflutterapp/dispatch/Pending_Scan_upload.dart';
import 'package:aljeflutterapp/dispatch/New_PickingMan.dart';
import 'package:aljeflutterapp/dispatch/New_Truckscanpage.dart';
import 'package:aljeflutterapp/dispatch/PickScanListPage.dart';
// import 'package:aljeflutterapp/dispatch/LiveStagingPage.dart';
import 'package:aljeflutterapp/dispatch/ReturnDispatch.dart';
import 'package:aljeflutterapp/dispatch/Shipment_Truck_Page.dart';
import 'package:aljeflutterapp/dispatch/Stage_Return.dart';
import 'package:aljeflutterapp/dispatch/masterProductcodeUpdat.dart';
import 'package:aljeflutterapp/dispatch/InterORGTransfer.dart';
import 'package:aljeflutterapp/dispatch/on_progress_dispatch/on_progress_dispatch_page.dart';
import 'package:aljeflutterapp/dispatch/Return%20Re--Dispatch/Return_Re-Dispatch_main_page.dart';
import 'package:aljeflutterapp/welcomedashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:aljeflutterapp/dispatch/CreateDispatch.dart';
import 'package:aljeflutterapp/dispatch/GeneratePickman.dart';
import 'package:aljeflutterapp/dispatch/NewGenerateDispatch.dart';

import 'package:flutter/material.dart';
import '../Reports/DeliveredView.dart';
import '../Reports/PickManPendingReport.dart';
import '../Reports/StagingReports.dart';
import '../components/Responsive.dart';
import 'package:aljeflutterapp/dashboard.dart';

import 'Swape_Super_Main_Page.dart';

class MainSidebar extends StatefulWidget {
  final int initialPageIndex;

  final List<String> enabledItems;
  MainSidebar({
    this.initialPageIndex = 0,
    required this.enabledItems, // Required parameter for enabledItems
  });

  @override
  _MainSidebarState createState() => _MainSidebarState();
}

// Class to hold page information
class PageInfo {
  final Widget page;
  final String title;
  final IconData icon;
  final bool isMainPage;

  PageInfo({
    required this.page,
    required this.title,
    required this.icon,
    this.isMainPage = true,
  });
}

class _MainSidebarState extends State<MainSidebar> {
  int _currentIndex = 0;
  bool _isOpen = true;
  bool _isDarkMode = false;
  List<int> _breadcrumbIndices = [];
  late List<bool> _enabledItems;

  String? saveloginrole = '';
  String? saveloginname = '';
  String? commersialrole = '';
  String shipmentIdPassed = '';

  // Map to hold all pages with their keys
  final Map<int, PageInfo> _allPages = {};

  @override
  void initState() {
    super.initState();
    _loadSalesmanName();
    getConnectionName();
    loadAccessStatus();
    _initializePages();
    _currentIndex = widget.initialPageIndex;
    _breadcrumbIndices.add(_currentIndex);
  }

  void loadAccessStatus() async {
    await fetchSwapewhrSuperuserStatus();
    setState(() {}); // refresh UI after getting API result
  }

  bool swapewhrsuperuser = false;
  Future<bool> fetchSwapewhrSuperuserStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String superuserno = prefs.getString('salesloginno') ?? '';

      final ipAddress = await getActiveIpAddress();
      final url =
          Uri.parse("$ipAddress/Get_employee_access_type/$superuserno/");

      // print("API URL: $url");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData["status"] == "success") {
          final data = jsonData["data"][0];
          String enableStatus = data["enable_status"].toString().toLowerCase();

          swapewhrsuperuser = (enableStatus == "true");

          // print("swapewhrsuperuser = $swapewhrsuperuser");

          return swapewhrsuperuser;
        }
      }

      swapewhrsuperuser = false;
      return false;
    } catch (e) {
      print("Error fetching WHR Superuser: $e");
      swapewhrsuperuser = false;
      return false;
    }
  }

  Future<void> _loadSalesmanName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      saveloginname = prefs.getString('saveloginname') ?? 'Unknown Salesman';
      saveloginrole = prefs.getString('salesloginrole') ?? 'Unknown Salesman';
      commersialrole = prefs.getString('commersialrole') ?? 'Unknown Salesman';

      // Initialize _enabledItems based on the passed widget.enabledItems
      _enabledItems = _getMainPages().asMap().entries.map((entry) {
        return entry.key == 0
            ? true
            : widget.enabledItems.contains(entry.value.title);
      }).toList();
    });
  }

  void _initializePages() {
    // Initialize all pages with their keys
    _allPages[0] = PageInfo(
      page: const Dashboard(),
      title: 'Dashboard',
      icon: Icons.dashboard,
    );

    _allPages[1] = PageInfo(
      page: const CreateDispatch(),
      title: 'Create Dispatch',
      icon: Icons.local_shipping_outlined,
    );

    _allPages[2] = PageInfo(
      page: OnProgressDispatchPage(togglePageGeneratePicking,
          EdittogglePageViewDispatchReports, togglePageGeneratedispatch),
      title: 'On Progress Dispatch',
      icon: Icons.delivery_dining,
    );

    _allPages[3] = PageInfo(
      page: PickManPendingReport(),
      title: 'Pending Pick',
      icon: Icons.pending,
    );

    _allPages[4] = PageInfo(
      page: ViewPicking(),
      title: 'View Pick',
      icon: Icons.visibility,
    );

    _allPages[5] = PageInfo(
      page: StagingReports(),
      title: 'Staging View',
      icon: Icons.view_module,
    );

    _allPages[6] = PageInfo(
      page: LoadInTruckPage(togglePageGeneratedispatch, '', '', '', '', '', ''),
      title: 'Load Intruck',
      icon: Icons.local_shipping,
    );

    _allPages[7] = PageInfo(
      page: CompletedDispatchPage(togglePageViewDispatchReports),
      title: 'Fulfilled Dispatch',
      icon: Icons.check_circle_outline,
    );

    _allPages[8] = PageInfo(
      page: ShippingVieew(),
      title: 'Shipped View',
      icon: Icons.local_shipping_outlined,
    );

    _allPages[9] = PageInfo(
      page: Delivery_Status_page(),
      title: 'Pending Scan',
      icon: Icons.track_changes,
    );

    _allPages[10] = PageInfo(
      page: ReturnDispatch(togglePageReturnconcepts),
      title: 'Received',
      icon: Icons.assignment_return,
    );

    _allPages[11] = PageInfo(
      page: Return_re_dispatch_page(
          togglePageGeneratePicking, EdittogglePageViewDispatchReports),
      title: 'Re-Dispatch',
      icon: Icons.replay_circle_filled,
    );

    _allPages[12] = PageInfo(
      page: MasterProductCodeUPdate(),
      title: 'Update Productcode',
      icon: Icons.qr_code_scanner,
    );

    _allPages[13] = PageInfo(
      page: invoicedetialsreports(),
      title: 'Report',
      icon: Icons.bar_chart,
    );

    _allPages[14] = PageInfo(
      page: PickScanListPage(togglePagePickman),
      title: 'Pick Scan List',
      icon: Icons.qr_code_2,
    );

    _allPages[15] = PageInfo(
      page: PickedView(togglePagePickmanReport),
      title: 'Picked View',
      icon: Icons.checklist,
    );

    _allPages[16] = PageInfo(
      page: Stage_returnView(''),
      title: 'Staging Return',
      icon: Icons.keyboard_return,
    );

    _allPages[17] = PageInfo(
      page: Live_StagingPage(togglePageTruckscanpageh),
      title: 'Live Stage',
      icon: Icons.directions_car_filled,
    );

    // Sub pages (not shown in main sidebar)
    _allPages[18] = PageInfo(
      page: Generatepicking(''),
      title: 'Generate Picking',
      icon: Icons.fact_check,
    );

    _allPages[19] = PageInfo(
      page: ViewDispatch(
          '', false, false, toggledispatchrequestpagefromviewdispatch),
      title: 'View Dispatch',
      icon: Icons.article_outlined,
      // isMainPage: false,
    );

    _allPages[20] = PageInfo(
      page: PickingManpage(togglePagePickmaMainpage),
      title: 'Pickup Man',
      icon: Icons.people_alt,
      // isMainPage: false,
    );

    _allPages[21] = PageInfo(
      page: PickManViewReport(),
      title: 'Pick Man View',
      icon: Icons.person_pin,
      // isMainPage: false,
    );

    _allPages[22] = PageInfo(
      page: TruckScanList(togglePageGeneratedispatch, '', '', '', '', '', ''),
      title: 'Truck Scan List',
      icon: Icons.qr_code,
      // isMainPage: false,
    );

    _allPages[23] = PageInfo(
      page: GenerateDispatch(togglePageGeneraldispatch, '', '', '', '', '', ''),
      title: 'Generate Dispatch',
      icon: Icons.auto_fix_high,
      // isMainPage: false,
    );

    _allPages[24] = PageInfo(
      page: DeliveredView(togglePageGeneratePicking),
      title: 'Delivered View',
      icon: Icons.inventory_2,
      // isMainPage: false,
    );

    _allPages[25] = PageInfo(
      page: Inter_ORG_Transfer(togglePageViewShipmentTrucking),
      title: 'Inter ORG Transfer',
      icon: Icons.compare_arrows,
      // isMainPage: false,
    );

    _allPages[26] = PageInfo(
      page:
          Shipment_Truck_page(togglePageViewShipmentinvoice, shipmentIdPassed),
      title: 'Shipment Trucking',
      icon: Icons.fire_truck,
      // isMainPage: false,
    );

    _allPages[27] = PageInfo(
      page: Inter_ORG_Main_page(),
      title: 'Inter Org View',
      icon: Icons.bar_chart_rounded,
      // isMainPage: false,
    );

    _allPages[28] = PageInfo(
      page: Return_invoice(),
      title: 'Invoice Return',
      icon: Icons.assignment_returned,
      // isMainPage: false,
    );

    _allPages[29] = PageInfo(
      page: RI_Report_page(),
      title: 'IR Report',
      icon: Icons.receipt_long,
      // isMainPage: false,
    );

    _allPages[30] = PageInfo(
      page: BayanExpense(),
      title: 'Bayan Expense',
      icon: Icons.attach_money,
      // isMainPage: false,
    );

    _allPages[31] = PageInfo(
      page: InboundInitiatorEntryPage(),
      title: 'Inbound Entry',
      icon: Icons.input,
      // isMainPage: false,
    );
  }

  // Get only main pages for the sidebar
  List<PageInfo> _getMainPages() {
    return _allPages.entries
        .where((entry) => entry.value.isMainPage)
        .map((entry) => entry.value)
        .toList();
  }

  // Get the current page widget
  Widget get _currentPage {
    return _allPages[_currentIndex]?.page ?? const SizedBox();
  }

  OverlayEntry? _overlayEntry;
  bool _isTooltipVisible = false;

  void _showTooltip(BuildContext context, Offset iconPosition) {
    if (_isTooltipVisible) return; // Prevent multiple tooltips at the same time

    _isTooltipVisible = true;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: iconPosition.dx + 50, // Adjust to center the tooltip
        top: iconPosition.dy - 40, // Position above the icon
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              saveloginname ?? "Unknown User",
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(_overlayEntry!);

    // Auto-hide the tooltip after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      _removeTooltip();
    });
  }

  void _removeTooltip() {
    if (!_isTooltipVisible) return;

    _overlayEntry?.remove();
    _overlayEntry = null;
    _isTooltipVisible = false;
  }

  bool _isMobile(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width < 600; // Define mobile based on screen width
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = !Responsive.isMobile(context);

    return VersionDialogWrapper(
      child: Scaffold(
        appBar: !isDesktop
            ? AppBar(
                title: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _allPages[_currentIndex]?.title ?? 'Unknown Page',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTapDown: (details) {
                          if (_isMobile(context)) {
                            _showTooltip(context, details.globalPosition);
                          }
                        },
                        onTapCancel: _removeTooltip,
                        onTapUp: (_) => _removeTooltip(),
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/images/user.png",
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                            const Icon(
                              Icons.arrow_drop_down_outlined,
                              size: 27,
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
        drawer: !isDesktop
            ? Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Drawer(
                  width: MediaQuery.of(context).size.width * 0.51,
                  child: toggle(context, isDesktop),
                ),
              )
            : null,
        body: Row(
          children: [
            if (!Responsive.isMobile(context)) toggle(context, isDesktop),
            Expanded(
              child: Container(
                color: _isDarkMode ? Colors.grey[850] : Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBreadcrumb(),
                    Expanded(
                      child: _allPages[_currentIndex]?.page ?? const SizedBox(),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrentPageTitle() {
    return _breadcrumbIndices
        .map((index) => _allPages[index]?.title ?? 'Unknown Page')
        .join(' > ');
  }

  Widget _buildBreadcrumb() {
    double screenWidth = MediaQuery.of(context).size.width;
    double formWidth =
        screenWidth > 900 ? screenWidth * 0.5 : screenWidth * 0.9;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              padding: const EdgeInsets.all(8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _breadcrumbIndices.asMap().entries.map((entry) {
                    int index = entry.key;
                    int pageIndex = entry.value;
                    String title = _allPages[pageIndex]?.title ?? 'Unknown';
                    Color textColor =
                        _currentIndex == pageIndex ? Colors.blue : Colors.grey;

                    return Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentIndex = pageIndex;
                              _breadcrumbIndices =
                                  _breadcrumbIndices.sublist(0, index + 1);
                            });
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 13,
                                color: _isDarkMode ? Colors.white : textColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            if (swapewhrsuperuser && saveloginrole == 'WHR SuperUser')
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        insetPadding: EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Container(
                          width: formWidth,
                          height: MediaQuery.of(context).size.height * 0.5,
                          padding: EdgeInsets.all(10),
                          child: Swape_WHR_Superuser(),
                        ),
                      );
                    },
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.logout,
                      size: 22,
                      color: _isDarkMode ? Colors.white : Colors.black,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      Responsive.isMobile(context) ? '' : 'Swape WHR SuperUser',
                      style: TextStyle(
                        fontSize: 14,
                        color: _isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.only(
                  right: (commersialrole == 'Sales Supervisor' ||
                          commersialrole == "Retail Sales Supervisor")
                      ? 0
                      : 20),
              child: MouseRegion(
                cursor: SystemMouseCursors.click, // Change cursor to hand icon

                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Container(
                            width: 300,
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  (commersialrole == 'Sales Supervisor' ||
                                          commersialrole ==
                                              "Retail Sales Supervisor")
                                      ? 'Switch Account'
                                      : 'Logout',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  (commersialrole == 'Sales Supervisor' ||
                                          commersialrole ==
                                              "Retail Sales Supervisor")
                                      ? 'Are you sure you want to Switch Account?'
                                      : 'Are you sure you want to logout from this department?',
                                  style: TextStyle(fontSize: 13),
                                ),
                                SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      },
                                      child: Text("No"),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        print(
                                            "commersialno commersialno $commersialrole");
                                        // Add your logout logic here
                                        print("User logged out");
                                        Navigator.of(context).pop();
                                        if (commersialrole ==
                                                'Sales Supervisor' ||
                                            commersialrole ==
                                                "Retail Sales Supervisor") {
                                          await SharedPrefs.clearAll();
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Commersial_Form()),
                                          );
                                          postLogData("Switch", "Switch");
                                        } else {
                                          await SharedPrefs
                                              .cleardatadepartmentexchangeforother();
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    WelcomeDashboard(
                                                      emailController:
                                                          TextEditingController(),
                                                    )),
                                          );
                                          postLogData("Logout", "Logout");
                                        }
                                      },
                                      child: Text("Yes"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.logout,
                        size: 22,
                        color: _isDarkMode ? Colors.white : Colors.black,
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        Responsive.isMobile(context)
                            ? (commersialrole == 'Sales Supervisor' ||
                                    commersialrole == "Retail Sales Supervisor")
                                ? ''
                                : 'Logout'
                            : (commersialrole == 'Sales Supervisor' ||
                                    commersialrole == "Retail Sales Supervisor")
                                ? 'Switch Account'
                                : 'Logout',
                        style: TextStyle(
                          fontSize: 14,
                          color: _isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if ((commersialrole == 'Sales Supervisor' ||
                commersialrole == "Retail Sales Supervisor"))
              Padding(
                padding: EdgeInsets.only(right: 20),
                child: MouseRegion(
                  cursor:
                      SystemMouseCursors.click, // Change cursor to hand icon
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Container(
                              width: 300,
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Logout',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    'Are you sure you want to logout with this department?',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                        child: Text("No"),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          print(
                                              "commersialno commersialno $commersialrole");
                                          // Add your logout logic here
                                          print("User logged out");
                                          Navigator.of(context).pop();
                                          {
                                            await SharedPrefs
                                                .cleardatadepartmentexchange();

                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      WelcomeDashboard(
                                                        emailController:
                                                            TextEditingController(),
                                                      )),
                                            );
                                          }
                                          postLogData("Logout", "Logout");
                                        },
                                        child: Text("Yes"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.logout,
                          size: 22,
                          color: _isDarkMode ? Colors.white : Colors.black,
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            color: _isDarkMode ? Colors.white : Colors.black,
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
    );
  }

  void togglePageGeneratePicking(String pagename) {
    setState(() {
      _currentIndex = 18; // Navigate to TrukLoadingScan
      _updateBreadcrumb(_currentIndex);

      // Pass the parameter to the page
      _allPages[_currentIndex] = PageInfo(
        page: Generatepicking(pagename),
        title: _allPages[_currentIndex]?.title ?? '',
        icon: _allPages[_currentIndex]?.icon ?? Icons.pages,
        isMainPage: _allPages[_currentIndex]?.isMainPage ?? false,
      );
    });
  }

  void togglePageReturnconcepts() {
    setState(() {
      _currentIndex = 10; // Navigate directly to Generate Picking
      _updateBreadcrumb(_currentIndex);
    });
  }

  void togglePagePickman() {
    setState(() {
      _currentIndex = 20; // Navigate directly to Pickup Man
      _updateBreadcrumb(_currentIndex);
    });
  }

  void togglePagePickmaMainpage() {
    setState(() {
      _currentIndex = 14; // Navigate directly to Pickup Man
      _updateBreadcrumb(_currentIndex);
    });
  }

  void togglePageGeneratedispatch(String reqno, String pickno, String cusno,
      String cusname, String cussite, String pickedqty) {
    setState(() {
      _currentIndex = 23; // Navigate to TrukLoadingScan
      _updateBreadcrumb(_currentIndex);

      // Pass the parameter to the page
      _allPages[_currentIndex] = PageInfo(
        page: GenerateDispatch(togglePageGeneraldispatch, reqno, pickno, cusno,
            cusname, cussite, pickedqty),
        title: _allPages[_currentIndex]?.title ?? '',
        icon: _allPages[_currentIndex]?.icon ?? Icons.pages,
        isMainPage: _allPages[_currentIndex]?.isMainPage ?? false,
      );
    });
  }

  void togglePageTruckscanpageh(String reqno, String pickno, String cusno,
      String cusname, String cussite, String pickedqty) {
    setState(() {
      _currentIndex = 22; // Navigate to TrukLoadingScan
      _breadcrumbIndices.add(_currentIndex);

      // Update the page in _allPages with the new parameters
      _allPages[_currentIndex] = PageInfo(
        page: TruckScanList(togglePageGeneratedispatch, reqno, pickno, cusno,
            cusname, cussite, pickedqty),
        title: 'Truck Scan List',
        icon: Icons.qr_code,
        isMainPage: false,
      );
    });
  }

  void togglePageViewDispatchReports(String reqno, bool CheckEdit) {
    setState(() {
      _currentIndex = 19; // Navigate to ViewDispatch
      _breadcrumbIndices.add(_currentIndex);

      // Update the page in _allPages with the new parameters
      _allPages[_currentIndex] = PageInfo(
        page: ViewDispatch(
            reqno, true, CheckEdit, toggledispatchrequestpagefromviewdispatch),
        title: 'View Dispatch',
        icon: Icons.article_outlined,
        isMainPage: false,
      );
    });
  }

  void EdittogglePageViewDispatchReports(String reqno, bool CheckEdit) {
    setState(() {
      _currentIndex = 19; // Navigate to ViewDispatch
      _breadcrumbIndices.add(_currentIndex);

      // Update the page in _allPages with the new parameters
      _allPages[_currentIndex] = PageInfo(
        page: ViewDispatch(
            reqno, false, CheckEdit, toggledispatchrequestpagefromviewdispatch),
        title: 'View Dispatch',
        icon: Icons.article_outlined,
        isMainPage: false,
      );
    });
  }

  void _updateBreadcrumb(int newIndex) {
    setState(() {
      if (_breadcrumbIndices.contains(newIndex)) {
        // If already in the breadcrumb, remove all indices after it
        int currentPosition = _breadcrumbIndices.indexOf(newIndex);
        _breadcrumbIndices = _breadcrumbIndices.sublist(0, currentPosition + 1);
      } else {
        // Otherwise, add the new index
        _breadcrumbIndices.add(newIndex);
      }
    });
  }

  void togglePagePickmanReport() {
    setState(() {
      _currentIndex = 21; // Navigate directly to Pickup Man
      _updateBreadcrumb(_currentIndex);
    });
  }

  void togglePageGeneraldispatch() {
    setState(() {
      _currentIndex = 6; // Navigate to LoadInTruckPage
      _breadcrumbIndices.add(_currentIndex);

      // Update the page in _allPages with default parameters
      _allPages[_currentIndex] = PageInfo(
        page:
            LoadInTruckPage(togglePageGeneratedispatch, '', '', '', '', '', ''),
        title: 'Load Intruck',
        icon: Icons.local_shipping,
        isMainPage: true,
      );
    });
  }

  void toggledispatchrequestpagefromviewdispatch() {
    setState(() {
      _currentIndex = 2; // Navigate to OnProgressDispatch
      _breadcrumbIndices.add(_currentIndex);

      // Update the page in _allPages
      _allPages[_currentIndex] = PageInfo(
        page: OnProgressDispatchPage(togglePageGeneratePicking,
            EdittogglePageViewDispatchReports, togglePageGeneratedispatch),
        title: 'On Progress Dispatch',
        icon: Icons.delivery_dining,
        isMainPage: true,
      );
    });
  }

  void togglePageViewShipmentTrucking(String shipmentid) {
    setState(() {
      shipmentIdPassed = shipmentid;

      _currentIndex = 26;
      _updateBreadcrumb(_currentIndex);
    });
  }

  void togglePageViewShipmentinvoice() {
    setState(() {
      _currentIndex = 25;
      _updateBreadcrumb(_currentIndex);
    });
  }

  List<bool> accessControl = [];

  Future<void> fetchAccessControl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesloginnoStr = prefs.getString('salesloginno');
    final String uniqueId = salesloginnoStr.toString();

    final IpAddress = await getActiveIpAddress();

    String apiUrl = '$IpAddress/User_member_details/';
    bool userFound = false;

    try {
      // Loop through each page until the user with uniqueId is found or no more pages are left
      while (apiUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
          // Decode the JSON response
          final data = json.decode(response.body);

          // Find the user with the matching unique_id on the current page
          var user = (data['results'] as List<dynamic>).firstWhere(
            (u) => u['unique_id'] == uniqueId,
            orElse: () => null,
          );

          if (user != null) {
            userFound = true;

            // Check if access_control is not null and is a Map
            var accessControlMap = user['acess_control'];
            if (accessControlMap != null && accessControlMap is Map) {
              // Convert access_control Map to a list of bools
              List<bool> accessControlList = [];

              // Iterate through the values of the access control map
              for (var value in accessControlMap.values) {
                // Ensure that we only process boolean values
                accessControlList
                    .add(value is bool ? value : value.toString() == 'true');
              }

              // Set the access control list to a state variable if needed
              setState(() {
                accessControl =
                    accessControlList; // Assuming accessControl is defined as List<bool>
              });

              print('Access Control List: $accessControl');
            } else {
              print('Access control data is not available for user $uniqueId.');
            }
            return; // Exit once the user is found and processed
          }

          // Update apiUrl to the next page, or set to empty if no more pages
          apiUrl = data['next'] ?? '';
        } else {
          print('Failed to load user details: ${response.statusCode}');
          return;
        }
      }

      if (!userFound) {
        print('User with unique_id $uniqueId not found in any page.');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  String? connectionName = '';

  Future<void> getConnectionName() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('database_connections');

    if (jsonStr != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonStr);
        final connections = jsonList.cast<Map<String, dynamic>>();

        for (var conn in connections) {
          if (conn['status'] == 'Active') {
            setState(() {
              connectionName = conn['name']?.toString() ?? '';
            });
            return;
          }
        }
      } catch (e) {
        print("Error parsing JSON: $e");
      }
    }

    setState(() {
      connectionName = 'No active connection';
    });
  }

  AnimatedContainer toggle(BuildContext context, bool isDesktop) {
    final mainPages = _getMainPages(); // Get only main pages for the sidebar

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isOpen ? 250 : 100,
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.black : Colors.white,
        border: Border.all(
          color: Colors.grey[400]!,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.6),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 8),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: Container(
          height: Responsive.isDesktop(context)
              ? MediaQuery.of(context).size.height * 1.6
              : 1200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!Responsive.isMobile(context))
                _isOpen
                    ? Column(
                        children: [
                          SizedBox(
                            height: 15,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isOpen = !_isOpen;
                              });
                            },
                            child: Image.asset(
                              'assets/images/logo.jpg',
                              height: 80,
                              width: 210,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 10),
                        child: IconButton(
                          icon: Icon(
                            Icons.menu,
                            size: 25,
                            color: _isDarkMode ? Colors.white : Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              _isOpen = !_isOpen;
                            });
                          },
                        ),
                      ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$Version',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Connection Name - $connectionName',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.grey[500]),
              if (_isOpen) ...[
                for (int i = 0; i < mainPages.length; i++)
                  if (_enabledItems[i])
                    _buildMenuItem(mainPages[i].title,
                        _getPageKey(mainPages[i]), mainPages[i].icon),
              ],
              if (!_isOpen) ...[
                for (int i = 0; i < mainPages.length; i++)
                  if (_enabledItems[i])
                    _buildIconItem(
                        _getPageKey(mainPages[i]), mainPages[i].icon),
              ],
              SizedBox(
                height: Responsive.isDesktop(context) ? 20 : 40,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to get the key for a PageInfo object
  int _getPageKey(PageInfo pageInfo) {
    return _allPages.entries.firstWhere((entry) => entry.value == pageInfo).key;
  }

  int _hoveredIndex = -1;

  void _onHover(int index, bool isHovering) {
    setState(() {
      _hoveredIndex = isHovering ? index : -1;
    });
  }

  Widget _buildMenuItem(String title, int index, IconData icon) {
    // Check if this is the first item in the "On Going Progress" section
    bool isFirstProgressItem = title == 'On Progress Dispatch';

    bool isFirstShippedView = title == 'Fulfilled Dispatch';

    bool isFirstReturn = title == 'Received';

    bool isFirstReturninvoice = title == 'Invoice Return';

    bool isFistPickmanscan = title == 'Pick Scan List';

    bool isFistLoadingView = title == 'Live Stage';

    bool isFirstInterORG = title == 'Inter ORG Transfer';

    bool isFirstInvoiceReport = title == 'Report';

    String Subheading = '';
    if (isFirstProgressItem) {
      Subheading = "On Going Progress";
    } else if (isFirstShippedView) {
      Subheading = "Delivered View";
    } else if (isFirstReturn) {
      Subheading = "Rejected Delivery";
    } else if (isFirstReturninvoice) {
      Subheading = "Invoice Return Details";
    } else if (isFistPickmanscan) {
      Subheading = "PickMan Scaned View";
    } else if (isFistLoadingView) {
      Subheading = "Loading Details";
    } else if (isFirstInterORG) {
      Subheading = "Inter Org View";
    } else if (isFirstInvoiceReport) {
      Subheading = "Invoice Report";
    }
    return Column(
      children: [
        if (isFirstProgressItem ||
            isFirstShippedView ||
            isFirstReturn ||
            isFirstReturninvoice ||
            isFistPickmanscan ||
            isFistLoadingView ||
            isFirstInterORG ||
            isFirstInvoiceReport) // Add heading before the first progress item
          Padding(
            padding: EdgeInsets.only(
              left: Responsive.isMobile(context) ? 3 : 8,
              top: 4,
              bottom: 3,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Subheading,
                style: TextStyle(
                  fontSize: Responsive.isMobile(context) ? 12 : 12,
                  color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        GestureDetector(
          onTap: () {
            setState(() {
              _currentIndex = index;
              _updateBreadcrumb(
                  _currentIndex); // Update breadcrumb on menu item tap
            });
            if (Responsive.isMobile(context)) Navigator.of(context).pop();
          },
          child: Padding(
            padding: EdgeInsets.only(
                left: Responsive.isMobile(context) ? 3 : 10,
                right: Responsive.isMobile(context) ? 3 : 10,
                top: 5),
            child: Container(
              width: !Responsive.isMobile(context)
                  ? MediaQuery.of(context).size.width * 0.3
                  : MediaQuery.of(context).size.width * 0.45,
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? (_isDarkMode
                        ? Colors.blue.withOpacity(0.5)
                        : Colors.blue.withOpacity(0.3))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      icon,
                      size: !Responsive.isMobile(context)
                          ? 17
                          : MediaQuery.of(context).size.width * 0.036,
                      color: _currentIndex == index
                          ? Colors.blue
                          : (_isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                  SizedBox(
                      width: !Responsive.isMobile(context)
                          ? 5
                          : MediaQuery.of(context).size.width * 0.01),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: !Responsive.isMobile(context)
                              ? MediaQuery.of(context).size.width * 0.1
                              : MediaQuery.of(context).size.width * 0.35,
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: !Responsive.isMobile(context)
                                  ? 13
                                  : MediaQuery.of(context).size.width * 0.036,
                              color: _currentIndex == index
                                  ? Colors.blue
                                  : (_isDarkMode ? Colors.white : Colors.black),
                            ),
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
        if (saveloginrole == 'Salesman')
          if (title != 'Pending Pick' &&
              title != 'View Pick' &&
              title != 'Staging View' &&
              title != 'Shipped View' &&
              title != 'Received' &&
              title != 'Inter ORG Transfer' &&
              title != 'Pick Scan List')
            Divider(color: const Color.fromARGB(255, 163, 163, 163)),
        if (saveloginrole != 'Salesman')
          if (title != 'On Progress Dispatch' &&
              title != 'Pending Pick' &&
              title != 'View Pick' &&
              title != 'Staging View' &&
              title != 'Shipped View' &&
              title != 'Fulfilled Dispatch' &&
              title != 'Received' &&
              title != 'Inter ORG Transfer' &&
              title != 'Pick Scan List' &&
              title != 'Invoice Return')
            Divider(color: const Color.fromARGB(255, 163, 163, 163)),
      ],
    );
  }

  Widget _buildIconItem(int index, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: IconButton(
        onPressed: () {
          setState(() {
            _currentIndex = index;
            _updateBreadcrumb(_currentIndex); // Update breadcrumb on icon tap
          });
        },
        icon: Icon(
          icon,
          color: _currentIndex == index
              ? Colors.blue
              : (_isDarkMode ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
