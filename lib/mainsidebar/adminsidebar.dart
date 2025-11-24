import 'dart:math';
import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:aljeflutterapp/admin/AddRDBMS.dart';
import 'package:aljeflutterapp/admin/add_supervisor_access.dart';
import 'package:aljeflutterapp/admin/settings.dart';
import 'package:aljeflutterapp/admin/updateemployee.dart';
import 'package:aljeflutterapp/components/Responsive.dart';
import 'package:aljeflutterapp/main.dart';
import 'package:flutter/material.dart';
import 'package:aljeflutterapp/dashboard.dart'; // Assuming this is your Dashboard pages

class AdminSidebar extends StatefulWidget {
  final int initialPageIndex;

  AdminSidebar({this.initialPageIndex = 0});

  @override
  _AdminSidebarState createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
  int _currentIndex = 0;
  bool _isOpen = true;
  bool _isDarkMode = false;
  bool _isEmployeeSettingsOpen = false; // For managing the settings dropdown
  bool _isSettingsOpen = false; // For managing the settings dropdown
  List<int> _breadcrumbIndices = []; // To store breadcrumb indices

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialPageIndex;

    _pages = [
      const Dashboard(), // Dashboard page
      AddManagerPage(),
      AddSuperuserPage(),
      AddRolepage(),
      Add_Supervisor(),
      // Addsalesman()
    ];

    // Initialize the breadcrumb with the default index
    _breadcrumbIndices.add(_currentIndex);
  }

  final List<String> _titles = [
    'Dashboard',
    'Add Employee',
    'Search Employee',
    'Add RBAC',

    'Add Supervisor Access',
    // 'Add Pickman',
    // 'Add SalesMan',
  ];

  final List<IconData> _icons = [
    Icons.dashboard, // Dashboard icon
    Icons.person_add, // Add Manager icon
    Icons.search, // Add Superuser icon
    Icons.group_add, // Add Staff icon
    Icons.person_pin_circle, // Add Pickman icon

    // Icons.person_2, // Add Pickman icon
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: !isDesktop
          ? AppBar(
              title: Text(
                _titles[_currentIndex],
                style: const TextStyle(
                  fontSize: 22,
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
          if (isDesktop) toggle(context, isDesktop),
          Expanded(
            child: Container(
              color: _isDarkMode ? Colors.grey[850] : Colors.white,
              child: Column(
                children: [
                  _buildBreadcrumb(), // Breadcrumb display
                  Expanded(
                      child:
                          _pages[_currentIndex]), // Display the selected page
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  AnimatedContainer toggle(BuildContext context, bool isDesktop) {
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
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Add logo here
              if (_isOpen)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset(
                    'assets/images/logo.jpg', // Your logo path
                    height: 80,
                    width: 210,
                    fit: BoxFit.cover,
                  ),
                ),
              if (!_isOpen)
                IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    setState(() {
                      _isOpen = !_isOpen;
                    });
                  },
                ),
              if (_isOpen) ...[
                _buildMenuItem('Dashboard', 0, Icons.dashboard),
                _buildEmployeeMenu(),
                _buildSettingsMenu(),
              ],
              if (!_isOpen) ...[
                _buildIconItem(0, Icons.dashboard),
                _buildIconItem(
                    -1, Icons.settings), // Show settings icon when minimized
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeMenu() {
    return ExpansionTile(
      title: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Icon(Icons.perm_contact_calendar_sharp,
                color: _isDarkMode ? Colors.white : Colors.black),
            const SizedBox(width: 10),
            Text(
              'Employees',
              style: TextStyle(
                fontSize: 14,
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
      initiallyExpanded: _isEmployeeSettingsOpen,
      onExpansionChanged: (bool expanded) {
        setState(() {
          _isEmployeeSettingsOpen = expanded;
          if (expanded) {
            _isSettingsOpen =
                false; // Close settings when employees are expanded
          }
        });
      },
      children: [
        _buildSubMenuItem('Add  Employee', 1, Icons.person_add),
        _buildSubMenuItem('Search Employee', 2, Icons.search),
        // _buildSubMenuItem('Add Pickman', 4, Icons.person_pin_circle),
        // _buildSubMenuItem('Add Staff', 3, Icons.group_add),
        // _buildSubMenuItem('Add SalesMan', 5, Icons.person),
      ],
    );
  }

  Widget _buildSettingsMenu() {
    return ExpansionTile(
      title: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Icon(Icons.settings,
                color: _isDarkMode ? Colors.white : Colors.black),
            const SizedBox(width: 10),
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 14,
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
      initiallyExpanded: _isSettingsOpen,
      onExpansionChanged: (bool expanded) {
        setState(() {
          _isSettingsOpen = expanded;
          if (expanded) {
            _isEmployeeSettingsOpen =
                false; // Close employees when settings are expanded
          }
        });
      },
      children: [
        _buildSubMenuItem('Add RBAC', 3, Icons.group_add),
        _buildSubMenuItem('Add Supervisor Access', 4, Icons.person_pin_circle),
        // _buildSubMenuItem('Add Staff', 3, Icons.group_add),
        // _buildSubMenuItem('Add SalesMan', 5, Icons.person),
      ],
    );
  }

  Widget _buildMenuItem(String title, int index, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
          _updateBreadcrumb(_currentIndex);
          if (Responsive.isMobile(context)) {
            Navigator.pop(context);
          }
          // Update breadcrumb on menu item tap
        });

        if (Responsive.isMobile(context)) Navigator.of(context).pop();
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 0),
        child: Container(
          decoration: BoxDecoration(
            color: _currentIndex == index
                ? (_isDarkMode
                    ? Colors.blue.withOpacity(0.5)
                    : Colors.blue.withOpacity(0.3))
                : Colors.transparent, // No border color or special effects
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  icon,
                  color: _currentIndex == index
                      ? Colors.blue
                      : (_isDarkMode ? Colors.white : Colors.black),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: _currentIndex == index
                      ? Colors.blue
                      : (_isDarkMode ? Colors.white : Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubMenuItem(String title, int index, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 10, top: 0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
            _updateBreadcrumb(_currentIndex);
            if (Responsive.isMobile(context)) {
              Navigator.pop(context);
            }
            // Update breadcrumb on sub-menu tap
          });

          if (Responsive.isMobile(context)) Navigator.of(context).pop();
        },
        child: Container(
          width: 320,
          decoration: BoxDecoration(
            color: (_isEmployeeSettingsOpen || _isSettingsOpen) &&
                    _currentIndex == index
                ? Colors.lightBlueAccent.withOpacity(0.3)
                : Colors.transparent, // No border or extra effects
            borderRadius: BorderRadius.circular(15),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 8.0, top: 8.0, left: 8.0),
                  child: Icon(
                    icon,
                    color: _currentIndex == index
                        ? Colors.blue
                        : (_isDarkMode ? Colors.white : Colors.black),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 8.0, top: 8.0, left: 8.0, right: 4.0),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: _currentIndex == index
                          ? Colors.blue
                          : (_isDarkMode ? Colors.white : Colors.black),
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

  Widget _buildIconItem(int index, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: IconButton(
        onPressed: () {
          setState(() {
            _currentIndex = index;
            _updateBreadcrumb(index); // Update breadcrumb on icon tap
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

  Widget _buildBreadcrumb() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.6,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _breadcrumbIndices.asMap().entries.map((entry) {
                  int index = entry.key;
                  String title = _titles[entry.value];
                  Color textColor =
                      _currentIndex == entry.value ? Colors.blue : Colors.grey;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentIndex =
                            entry.value; // Navigate to selected breadcrumb
                        _breadcrumbIndices = _breadcrumbIndices.sublist(
                            0, index + 1); // Trim the breadcrumb
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        title,
                        style: TextStyle(
                          color: _isDarkMode ? Colors.white : textColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
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
                                "Logout",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                "Are you sure you want to logout?",
                                style: TextStyle(fontSize: 16),
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
                                      print("User logged out");
                                      Navigator.of(context).pop();

                                      await SharedPrefs.clearAll();
                                      // Add your logout logic here
                                      // Clear session and navigate to login page or home page
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MyHomePage()),
                                      );
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
                      color: _isDarkMode ? Colors.white : Colors.black,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
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
    );
  }

  void _updateBreadcrumb(int newIndex) {
    setState(() {
      if (_breadcrumbIndices.contains(newIndex)) {
        int currentPosition = _breadcrumbIndices.indexOf(newIndex);
        _breadcrumbIndices = _breadcrumbIndices.sublist(0, currentPosition + 1);
      } else {
        _breadcrumbIndices.add(newIndex);
      }
    });
  }
}

// Define your other pages below
class AddManagerPage extends StatefulWidget {
  const AddManagerPage({super.key});

  @override
  State<AddManagerPage> createState() => _AddManagerPageState();
}

class _AddManagerPageState extends State<AddManagerPage> {
  @override
  Widget build(BuildContext context) {
    return add_user(
      topbarname: "Add Employee",
      selectedaddrole: 'WHR SuperUser',
    );
  }
}

class AddSuperuserPage extends StatefulWidget {
  const AddSuperuserPage({super.key});

  @override
  State<AddSuperuserPage> createState() => _AddSuperuserPageState();
}

class _AddSuperuserPageState extends State<AddSuperuserPage> {
  @override
  Widget build(BuildContext context) {
    return Updateemployee(
      topbarname: "Search Employee",
      selectedaddrole: 'supervisor',
    );
  }
}

class AddRolepage extends StatefulWidget {
  const AddRolepage({super.key});

  @override
  State<AddRolepage> createState() => _AddRolepageState();
}

class _AddRolepageState extends State<AddRolepage> {
  @override
  Widget build(BuildContext context) {
    return Add_RDBMSPage(
      topbarname: "Add RBAC",
      selectedaddrole: 'admin',
    );
  }
}

class Add_Supervisor extends StatefulWidget {
  const Add_Supervisor({super.key});

  @override
  State<Add_Supervisor> createState() => _Add_SupervisorState();
}

class _Add_SupervisorState extends State<Add_Supervisor> {
  @override
  Widget build(BuildContext context) {
    return Add_Supervisor_access(
      topbarname: "Add Supervisor Access",
      selectedaddrole: 'admin',
    );
  }
}
