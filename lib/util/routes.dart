import 'package:inuachama/models/groups.dart';
import 'package:inuachama/pages/addtransaction.dart';
import 'package:inuachama/pages/adminpanel.dart';
import 'package:inuachama/pages/allmembers.dart';
import 'package:inuachama/pages/bills.dart';
import 'package:inuachama/pages/categorytransactions.dart';
import 'package:inuachama/pages/dashboard.dart';
import 'package:inuachama/pages/groupsettings.dart';
import 'package:inuachama/pages/login.dart';
import 'package:inuachama/pages/managepersonalpendingtransactions.dart';
import 'package:inuachama/pages/membermanagement.dart';
import 'package:inuachama/pages/profile.dart';
import 'package:inuachama/pages/transactionmanagement.dart';
import 'package:get/get.dart';

int transtionDuration = 200;
Transition transition = Transition.fadeIn;

class Routes {
  static final routes = [
    GetPage(
        name: '/',
        page: () => const LoginSignUpScreen(),
        transition: transition,
        transitionDuration: Duration(milliseconds: transtionDuration)),
    GetPage(
        name: '/addtransactions',
        page: () => const AddTransaction(),
        transition: transition,
        transitionDuration: Duration(milliseconds: transtionDuration)),
    GetPage(
        name: '/groups',
        page: () => const MyGroups(),
        transition: transition,
        transitionDuration: Duration(milliseconds: transtionDuration)),
    GetPage(
        name: '/dashboard',
        page: () => const DashBoard(),
        transition: transition,
        transitionDuration: Duration(milliseconds: transtionDuration)),
    GetPage(
        name: '/profile',
        page: () => const Profile(),
        transition: transition,
        transitionDuration: Duration(milliseconds: transtionDuration)),
    GetPage(
        name: '/adminpanel',
        page: () => const AdminPanel(),
        transition: transition,
        transitionDuration: Duration(milliseconds: transtionDuration)),
    GetPage(
        name: '/groupsettings',
        page: () => const GroupSettings(),
        transition: transition,
        transitionDuration: Duration(milliseconds: transtionDuration)),
    GetPage(
        name: '/membershipmanagement',
        page: () => const MemberManagement(),
        transition: transition,
        transitionDuration: Duration(milliseconds: transtionDuration)),
    GetPage(
        name: '/transactionmanagement',
        page: () => const ManageTransactions(),
        transition: transition,
        transitionDuration: Duration(milliseconds: transtionDuration)),
    GetPage(
        name: '/groupbilling',
        page: () => const Billing(),
        transition: transition,
        transitionDuration: Duration(milliseconds: transtionDuration)),
    GetPage(
        name: '/transactions',
        page: () => const SpecificTransactions(),
        transition: transition,
        transitionDuration: Duration(milliseconds: transtionDuration)),
    GetPage(
        name: '/members',
        page: () => const AllMembers(),
        transition: transition,
        transitionDuration: Duration(milliseconds: transtionDuration)),
    GetPage(
        name: '/pendingtransactions',
        page: () => const ManagePersonalPendingTransactions(),
        transition: transition,
        transitionDuration: Duration(milliseconds: transtionDuration)),
  ];
}
