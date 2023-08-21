import 'package:flutter/material.dart';
import 'package:inuachama/pages/home.dart';
import 'package:inuachama/pages/personalaccount.dart';
import 'package:inuachama/pages/profile.dart';
import 'package:inuachama/util/configurations.dart';

final Prefs _prefs = Prefs();
bool accessAll = false;
var userRole = "";

class DashBoard extends StatefulWidget {
  const DashBoard() : super();

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  int _selectedIndex = 0;

  void getClickedGroupDetails() {
    _prefs.getClickedGroup().then((group) => {
          setState(() => {
                userRole = group.userRoleInGroup,
                accessAll = group.isAccessReports,
              }),
        });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    getClickedGroupDetails();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = [];
    if (!accessAll ||
        userRole.compareTo("1") == 0 ||
        userRole.compareTo("2") == 0) {
      _widgetOptions.add(const Home() == null ? Container() : const Home());
    }
    //_widgetOptions.add(const ActivityHome());
    _widgetOptions.add(const PersonalAccount());
    //_widgetOptions.add(const ReportList());
    _widgetOptions.add(const Profile());
    List<BottomNavigationBarItem> groupMenu = [];
    if (!accessAll ||
        userRole.compareTo("1") == 0 ||
        userRole.compareTo("2") == 0) {
      groupMenu.add(menuIcon(Icons.dashboard, "Home"));
    }
    //groupMenu.add(menuIcon(Icons.notifications_none_rounded, "Activity"));
    groupMenu.add(menuIcon(Icons.account_circle_outlined, "Account"));
    //groupMenu.add(menuIcon(Icons.receipt_outlined, "Reports"));
    groupMenu.add(menuIcon(Icons.settings, "Settings"));
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
          showUnselectedLabels: true,
          items: groupMenu,
          type: BottomNavigationBarType.shifting,
          unselectedItemColor: priColor,
          currentIndex: _selectedIndex,
          selectedItemColor: adminColor,
          iconSize: 30,
          onTap: _onItemTapped,
          selectedLabelStyle: mainText(),
          unselectedLabelStyle: mainText(),
          backgroundColor: priAccentColor,
          elevation: 3),
    );
  }
}
