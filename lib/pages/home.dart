import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:inuachama/models/dashboarddata.dart';
import 'package:inuachama/models/mainmenu.dart';
import 'package:inuachama/models/members.dart';
import 'package:inuachama/models/transaction.dart';
import 'package:inuachama/pages/profile.dart';
import 'package:inuachama/util/configurations.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../util/responsive_manager.dart';

List<Member> members = [];
List<Member> allMembers = [];
bool loadingMembers = true;
List<Transaction> transactions = [];
List<Transaction> allTransactions = [];
List<Transaction> pendingLoanTrans = [];
String query = "";
String? _sortValue;
bool loadingTransactions = true;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController filterController = TextEditingController();
  final Prefs _prefs = Prefs();
  int availalbeCashTouchedIndex = -1;
  int loanDataTouchedIndex = -1;
  var userImage = "";
  var userRole = "";
  var userPhone = "";
  var userGroupCode = "";
  late bool loanModules = false;
  late bool membershipFee = false;
  late bool finesModule = false;
  late bool expensesModule = false;
  late bool adminRecords = false;
  late bool contributionEvents = false;
  late bool postForOthers = false;
  late bool capitalShare = false;
  late bool otherIncomes = false;
  bool getMpesaCode = false;
  var userActiveInGroup = "";
  var loanID = "";
  var myMembers = {};
  String groupName = "";
  late ScaffoldMessengerState scaffoldMessenger;
  late BuildContext contx;
  bool loadingTransactions = true;
  double availableCash = 0.0;
  double total_contribution = 0.0;
  double interest_paid_sofar = 0.0;
  TextEditingController amountController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  double membership_fee = 0.0;
  double total_fines = 0.0;
  double total_repayed_loans = 0.0;
  double total_group_expenses = 0.0;
  double total_taken_loans = 0.0;
  double current_month_highest_contribution = 0.0;
  double current_month_average_contribution = 0.0;
  double interest_this_month = 0.0;
  double total_share_capital = 0.0;
  double total_other_incomes = 0.0;
  double unpaidLoans = 0.0;
  double unpaidInterests = 0.0;
  double unpaidFines = 0.0;
  double cashIn = 0.0;
  List<String> transactionTypes = [];
  List<String> groupEvents = [];
  List<String> allMembers = [];
  List<String> userLoanIDS = [];
  List<String> items = [];
  List<String> events = [];
  List<String> members = [];
  List<String> loanIDs = [];
  List<Member> mems = [];
  List<Member> allMems = [];
  List<DashBoardData> allDashboardData = [];
  String dropDownValue = '';
  String selectedEvent = '';
  String selectedMember = '';
  String dropDownLoanID = '';
  var userFirstName, userLastName;
  List<MainMenu> myMainMenus = [];

  @override
  void initState() {
    super.initState();
    MpesaCode();
    getLoggedUser();
  }

  // @override
  // void dispose() {
  //   events.clear();
  //   transactionTypes.clear();
  //   super.dispose();
  // }

  void getLoggedUser() {
    _prefs.getLoggedUSer().then((user) => {
          setState(() => {
                userImage = user.image,
                userPhone = user.phone,
                userFirstName = user.fname,
                userLastName = user.lname,
                getClickedGroupDetails(),
              })
        });
  }

  void populateRecentTransactions() {
    transactions.clear();
    allTransactions.clear();
    _sortValue = null;
    Webservice().load(Transaction.recent(userGroupCode)).then((trans) => {
          setState(() => {
                allTransactions = trans,
                transactions = allTransactions,
                loadingTransactions = false
              })
        });
  }

  void pendingLoansTransactions() {
    pendingLoanTrans.clear();
    _sortValue = null;
    Webservice().load(Transaction.pendingLoans(userGroupCode)).then((trans) => {
          setState(
              () => {pendingLoanTrans = trans, loadingTransactions = false})
        });
  }

  void MpesaCode() {
    _prefs.getBooleanValuesSF('isMpesaCode').then((mpesa) => {
          setState(() => {
                getMpesaCode = mpesa!,
              })
        });
  }

  void getClickedGroupDetails() {
    _prefs.getClickedGroup().then((group) => {
          setState(() => {
                userRole = group.userRoleInGroup,
                groupName = group.groupName,
                userGroupCode = group.groupCode,
                loanModules = group.loansModule,
                membershipFee = group.membershipFeeModule,
                finesModule = group.finesModule,
                expensesModule = group.expensesModule,
                userActiveInGroup = group.userActiveInGroup,
                adminRecords = group.isAdminRecords,
                contributionEvents = group.isEventsContribution,
                capitalShare = group.isShareCapital,
                otherIncomes = group.isIncomeModule,
                getContributionEvents(),
                buildMenus(),
                populateRecentTransactions(),
                pendingLoansTransactions(),
              }),
        });
  }

  void _populateDashBoard() {
    Webservice()
        .load(DashBoardData.all(userGroupCode))
        .then((dashboarddata) => {
              getLoanIDS(),
              if (mounted)
                {
                  setState(() {
                    allDashboardData = dashboarddata;
                    total_contribution =
                        double.parse(allDashboardData[0].total_contribution);
                    interest_paid_sofar =
                        double.parse(allDashboardData[0].interest_paid_so_far);
                    membership_fee =
                        double.parse(allDashboardData[0].membership_fee);
                    total_fines = double.parse(allDashboardData[0].total_fines);
                    total_repayed_loans =
                        double.parse(allDashboardData[0].total_repayed_loans);
                    total_group_expenses =
                        double.parse(allDashboardData[0].total_group_expenses);
                    unpaidFines =
                        double.parse(allDashboardData[0].totalUnPaidFines);
                    unpaidInterests =
                        double.parse(allDashboardData[0].totalUnPaidInterest);
                    total_taken_loans =
                        double.parse(allDashboardData[0].total_taken_loans);
                    current_month_highest_contribution = double.parse(
                        allDashboardData[0].current_month_highest_contribution);
                    interest_this_month =
                        double.parse(allDashboardData[0].interest_this_month);
                    total_share_capital =
                        double.parse(allDashboardData[0].total_share_capital);
                    total_other_incomes =
                        double.parse(allDashboardData[0].total_other_incomes);
                    current_month_average_contribution = double.parse(
                        allDashboardData[0].current_month_average_contribution);
                    interest_this_month =
                        double.parse(allDashboardData[0].interest_this_month);
                    availableCash = (total_contribution +
                            total_share_capital +
                            interest_paid_sofar +
                            total_fines +
                            total_repayed_loans +
                            membership_fee +
                            total_other_incomes) -
                        (total_taken_loans + total_group_expenses);
                    unpaidLoans = total_taken_loans - total_repayed_loans;
                    cashIn =
                        total_contribution + interest_paid_sofar + total_fines;
                    loadingTransactions = false;
                    buildMenus();
                  })
                }
            });
  }

  @override
  Widget build(BuildContext context) {
    scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() {
      contx = context;
    });
    return Scaffold(
      backgroundColor: priColorShade,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: priColor,
        title: Text(
          (groupName.toString()),
          style: appBarText(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              Get.toNamed('/addtransactions');
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              _populateDashBoard();
              populateRecentTransactions();
              pendingLoansTransactions();
              //buildMenus();
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              showExitPopup(context);
            },
          )
        ],
        centerTitle: true,
      ),
      body: ResponsiveHelper(
        mobile: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            homeHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        color: priColorShade,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [],
                        ),
                      ),
                    ),
                    if (pendingLoanTrans.isNotEmpty && loanModules)
                      pendingLoans(),
                    recentTransactions(),
                    mainMenuList(),
                  ],
                ),
              ),
            ),
          ],
        ),
        desktop: Container(),
      ),
      // floatingActionButton: FloatingActionButton(
      //     elevation: 1,
      //     onPressed: () {
      //       Get.toNamed('/addtransactions');
      //     },
      //     backgroundColor: priColor,
      //     child: const Icon(
      //       Icons.add,
      //       color: secbgColor,
      //     )),
    );
  }

  Column recentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5, left: 10),
          child: Text(
            "Recent Transactions",
            style: labelPriColorText().copyWith(
                fontSize: 19, fontWeight: FontWeight.w900, color: greyColor),
          ),
        ),
        loadingTransactions
            ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(priColor),
                ),
              )
            : transactions.isEmpty
                ? emptyListView("No transactions added yet..")
                : Container(
                    height: 155,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: transactions.length,
                      itemBuilder: buildItemsForRecentTransactionsList,
                    ),
                  ),
      ],
    );
  }

  Column pendingLoans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5, left: 10),
          child: Text(
            "Pending Loans",
            style: labelPriColorText().copyWith(
                fontSize: 19, fontWeight: FontWeight.w900, color: greyColor),
          ),
        ),
        loadingTransactions
            ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(priColor),
                ),
              )
            : transactions.isEmpty
                ? emptyListView("No pending loans...")
                : SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: pendingLoanTrans.length,
                      itemBuilder: buildItemsForPendingLoansList,
                    ),
                  ),
      ],
    );
  }

  Widget mainMenuList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5, left: 10),
          child: Text(
            "Transaction Categories",
            style: labelPriColorText().copyWith(
                fontSize: 19, fontWeight: FontWeight.w900, color: greyColor),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(1.0),
          child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 1.0,
                crossAxisSpacing: 1.0,
              ),
              itemCount: myMainMenus.length,
              itemBuilder: _buildItemsForListView),
        )
      ],
    );
  }

  Widget homeHeader(BuildContext context) {
    return Card(
      shadowColor: priColorShade,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [priColorShade, priColorShade]),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: transparentColor,
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: "${urlRoot}profilepics/$userImage",
                          fit: BoxFit.cover,
                          width: 200,
                          height: 200,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(
                            strokeWidth: 0,
                            color: adminColor,
                          ),
                          errorWidget: (context, url, error) =>
                              Image.asset("assets/images/blank.png"),
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const Profile()),
                          (Route<dynamic> route) => true);
                    },
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        greeting(),
                        style: mainBoldText()
                            .copyWith(fontWeight: FontWeight.normal)
                            .copyWith(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      userFirstName.toString().isNotEmpty
                          ? Text(
                              userFirstName,
                              style: mainBoldText()
                                  .copyWith(fontWeight: FontWeight.w800)
                                  .copyWith(fontSize: 18),
                              textAlign: TextAlign.center,
                            )
                          : Container(),
                    ],
                  ),
                  const Spacer(),
                  if (userRole.compareTo("1") == 0 ||
                      userRole.compareTo("2") == 0)
                    adminActionButton("Admin", Icons.admin_panel_settings, () {
                      Get.toNamed('/adminpanel');
                    }),
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    groupAmountCard("Cash Available", availableCash),
                    if (loanModules)
                      groupAmountCard("Group Interest", interest_paid_sofar),
                    if (capitalShare)
                      groupAmountCard("Share Capital", total_share_capital),
                    if (otherIncomes)
                      groupAmountCard(
                          "Other Group Incomes", total_other_incomes),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Card groupAmountCard(title, amount) {
    return Card(
      color: secbgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: mainBoldText().copyWith(
                  fontSize: 18, fontWeight: FontWeight.w700, color: greyColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  forCurrency(amount),
                  style: mainBoldText().copyWith(color: greyColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container resourceCard(IconData icon, String label, VoidCallback action) {
    return Container(
      height: 80,
      width: 100,
      child: GestureDetector(
        onTap: action,
        child: Card(
          shadowColor: inactiveColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          elevation: 0,
          color: secbgColor,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: priColor,
                ),
                Text(
                  label,
                  style: labelWhiteText().copyWith(
                      fontSize: 14,
                      color: greyColor,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void getMembers() {
    var client = http.Client();
    client.post(Uri.parse("${urlRoot}getmembers.php?groupCode=$userGroupCode"),
        body: {}).then((response) {
      client.close();
      if (mounted && response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        members.clear();
        allMembers.clear();
        myMembers.clear();
        jsonResponse.forEach((s) {
          String memberName = s['fname'] + " " + s['lname'] + '\n' + s['phone'];
          allMembers.add(memberName);
          myMembers[memberName] = s['phone'];
        });
        setState(() {
          members = allMembers;
          members.sort((a, b) => a.compareTo(b));
          selectedMember = allMembers[0];
        });
      }
    });
  }

  void getTransactionTypes() {
    transactionTypes.clear();
    items.clear();
    var client = http.Client();
    client.post(
        Uri.parse('${urlRoot}gettransactioncats.php?groupCode=$userGroupCode'),
        body: {}).then((response) {
      client.close();
      if (mounted && response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        items.clear();
        transactionTypes.clear();
        jsonResponse.forEach((s) => transactionTypes.add(s['type_name']));
        setState(() {
          items = transactionTypes;
          dropDownValue = transactionTypes[0];
        });
      }
    });
    getMembers();
  }

  void getContributionEvents() {
    events.clear();
    groupEvents.clear();
    var client = http.Client();
    client.post(
        Uri.parse(
            '${urlRoot}contributionEvent.php?groupCode=$userGroupCode&category=getevents'),
        body: {}).then((response) {
      client.close();
      if (mounted && response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        events.clear();
        groupEvents.clear();
        jsonResponse.forEach((s) => groupEvents.add(s['title']));
        setState(() {
          events = groupEvents;
          if (groupEvents.isNotEmpty) selectedEvent = groupEvents[0];
        });
      }
    });
  }

  void getLoanIDS() {
    var client = http.Client();
    client.post(
        Uri.parse(
            '${urlRoot}getuserLoanIDs.php?phone=$userPhone&groupCode=$userGroupCode'),
        body: {}).then((response) {
      client.close();
      if (mounted && response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        userLoanIDS.clear();
        jsonResponse.forEach((s) => userLoanIDS.add(s['loanID']));
        setState(() {
          loanIDs = userLoanIDS;
          if (userLoanIDS.isNotEmpty) {
            dropDownLoanID = userLoanIDS[0];
          }
        });
      }
    });
  }

  Widget _buildItemsForListView(BuildContext context, int index) {
    return InkWell(
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        margin: const EdgeInsets.fromLTRB(5, 2, 5, 2),
        shadowColor: bgColor,
        borderOnForeground: false,
        elevation: 1.0,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 20,
                backgroundColor: priColor,
                child: Icon(
                  myMainMenus[index].icon,
                  color: secbgColor,
                  size: 30,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                myMainMenus[index].title.toUpperCase(),
                style:
                    labelBlackText().copyWith(color: greyColor, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                  myMainMenus[index].position == 0 ||
                          myMainMenus[index].position == 14
                      ? ''
                      : forCurrency(myMainMenus[index].value),
                  style: MainAccentText().copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.right),
            ],
          ),
        ),
      ),
      onTap: () {
        if (myMainMenus[index].position == 14) {
          Get.toNamed('/members');
        } else {
          Get.toNamed('/transactions', arguments: {
            'scope': 'group',
            'tTypes': myMainMenus[index].title.toString(),
            'url':
                'alltransactions_bycat.php?position=${myMainMenus[index].position}&groupCode=$userGroupCode'
          });
        }
      },
    );
  }

  void buildMenus() {
    myMainMenus.clear();
    MainMenu allTransactions = MainMenu(Icons.list_alt_outlined,
        'All Transactions', 'All transaction made to date', 0.0, 0);
    MainMenu allContributions = MainMenu(Icons.money, 'Contributions',
        'Total contributions by members', total_contribution, 1);
    MainMenu allCapitalShares = MainMenu(Icons.group_outlined, 'Share Capital',
        'Total share capital by members', total_share_capital, 2);
    MainMenu allLoansTaken = MainMenu(Icons.money, 'Loans Taken',
        'All loans taken by members', total_taken_loans, 3);
    MainMenu allRepaidLoan = MainMenu(Icons.backup_table, 'Loans Repaid',
        'All loans repaid by members', total_repayed_loans, 4);
    MainMenu allPaidFines = MainMenu(Icons.check_circle, 'Fines Paid',
        'All fines paid by members', total_fines, 5);
    MainMenu allPaidInterest = MainMenu(Icons.arrow_circle_up, 'Interest Paid',
        'All Interest paid to date', interest_paid_sofar, 6);
    MainMenu allUnpaidLoans = MainMenu(Icons.description, 'Unpaid Loans',
        'Loans yet to be paid by members', unpaidLoans, 7);
    MainMenu allUnpaidInterest = MainMenu(
        Icons.assessment_rounded,
        'Unpaid Interest',
        'Interest yet to be paid by members',
        unpaidInterests,
        8);
    MainMenu allUnpaidFines = MainMenu(Icons.timelapse_sharp, 'Unpaid Fines',
        'Fines yet to be paid by members', unpaidFines, 9);
    MainMenu currentMonthInterest = MainMenu(
        Icons.arrow_circle_up_rounded,
        '${getCurrentMonth().substring(0, 1).toUpperCase()}${getCurrentMonth().substring(1).toLowerCase()}\'s Interest',
        'Interest paid in ${getCurrentMonth().substring(0, 1).toUpperCase()}${getCurrentMonth().substring(1).toLowerCase()}',
        interest_this_month,
        10);
    MainMenu allGroupIncomes = MainMenu(Icons.arrow_drop_down_circle_rounded,
        'Group Incomes', 'All other group incomes', total_other_incomes, 11);
    MainMenu allGroupExpenses = MainMenu(
        Icons.arrow_drop_down_circle_rounded,
        'Group Expenses',
        'All group expenses incurred',
        total_group_expenses,
        12);
    MainMenu allMembershipFees = MainMenu(Icons.upgrade_outlined,
        'Membership Fees', 'Fee paid by joining members', membership_fee, 13);
    MainMenu allMembers = MainMenu(Icons.supervised_user_circle_sharp,
        'All Members', 'Group members profiles', 0.0, 14);

    if (loanModules) {
      myMainMenus.add(allLoansTaken);
      myMainMenus.add(allPaidInterest);
      myMainMenus.add(allUnpaidLoans);
      myMainMenus.add(allRepaidLoan);
      myMainMenus.add(allUnpaidInterest);
      myMainMenus.add(currentMonthInterest);
    }
    if (finesModule) {
      myMainMenus.add(allUnpaidFines);
      myMainMenus.add(allPaidFines);
    }
    if (membershipFee) {
      myMainMenus.add(allMembershipFees);
    }
    if (expensesModule) {
      myMainMenus.add(allGroupExpenses);
    }
    if (capitalShare) {
      myMainMenus.add(allCapitalShares);
    }
    if (capitalShare) {
      myMainMenus.add(allGroupIncomes);
    }
    myMainMenus.add(allMembers);
    myMainMenus.add(allTransactions);
    myMainMenus.add(allContributions);
    myMainMenus.sort((a, b) => a.position.compareTo(b.position));
    _populateDashBoard();
  }

  Widget buildItemsForRecentTransactionsList(BuildContext context, int index) {
    return SizedBox(
      width: 125,
      child: Card(
        shadowColor: inactiveColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        elevation: 0,
        color: secbgColor,
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: transparentColor,
                child: ClipOval(
                    child: CachedNetworkImage(
                        imageUrl: "${urlRoot}profilepics/" +
                            transactions[index].image,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(
                              color: adminColor,
                              strokeWidth: 1,
                            ),
                        errorWidget: (context, url, error) {
                          return Image.asset("assets/images/blank.png");
                        })),
              ),
              Text(
                transactions[index].name,
                style: labelWhiteText().copyWith(
                    fontSize: 14,
                    color: greyColor,
                    fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              Text(
                forCurrency(transactions[index].amount),
                style:
                    labelWhiteText().copyWith(fontSize: 13, color: greyColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                color: transactions[index]
                            .t_type
                            .toString()
                            .compareTo("Membership Fee") ==
                        0
                    ? priColorShade
                    : transactions[index]
                                .t_type
                                .toString()
                                .compareTo("Interest Payment") ==
                            0
                        ? greenColorShade
                        : transactions[index]
                                    .t_type
                                    .toString()
                                    .compareTo("Lateness Fine") ==
                                0
                            ? redColorShades
                            : transactions[index]
                                        .t_type
                                        .toString()
                                        .compareTo("Loan Request") ==
                                    0
                                ? goldColorShades
                                : transactions[index]
                                            .t_type
                                            .toString()
                                            .compareTo("Loan Payment") ==
                                        0
                                    ? blueColorShades
                                    : transactions[index]
                                                .t_type
                                                .toString()
                                                .compareTo("Share Capital") ==
                                            0
                                        ? pinkColorShades
                                        : transactions[index]
                                                    .t_type
                                                    .toString()
                                                    .compareTo(
                                                        "Group Income") ==
                                                0
                                            ? greenyColorShades
                                            : adminColorShade,
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Text(
                    transactions[index].t_type,
                    style: mainText()
                        .copyWith(fontWeight: FontWeight.w500, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildItemsForPendingLoansList(BuildContext context, int index) {
    return SizedBox(
      width: 125,
      child: Card(
        shadowColor: inactiveColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        elevation: 0,
        color: secbgColor,
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: transparentColor,
                    child: ClipOval(
                        child: CachedNetworkImage(
                            imageUrl: "${urlRoot}profilepics/" +
                                pendingLoanTrans[index].image,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(
                                  color: adminColor,
                                  strokeWidth: 1,
                                ),
                            errorWidget: (context, url, error) {
                              return Image.asset("assets/images/blank.png");
                            })),
                  ),
                  Card(
                    elevation: 2,
                    color: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("${index + 1}",
                          style: const TextStyle(
                              fontSize: 14,
                              color: secbgColor,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              Text(
                pendingLoanTrans[index].name,
                style: labelWhiteText().copyWith(
                    fontSize: 14,
                    color: greyColor,
                    fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              Text(
                forCurrency(pendingLoanTrans[index].amount),
                style:
                    labelWhiteText().copyWith(fontSize: 13, color: greyColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning,';
    }
    if (hour < 17) {
      return 'Good Afternoon,';
    }
    return 'Good Evening,';
  }
}
