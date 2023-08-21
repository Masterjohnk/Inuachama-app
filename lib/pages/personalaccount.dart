import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:inuachama/models/mainmenu.dart';
import 'package:inuachama/models/personaldashboarddata.dart';
import 'package:inuachama/pages/addtransaction.dart';
import 'package:inuachama/util/configurations.dart';
import 'package:get/get.dart';

class PersonalAccount extends StatefulWidget {
  const PersonalAccount({Key? key}) : super(key: key);

  @override
  _PersonalAccountState createState() => _PersonalAccountState();
}

class _PersonalAccountState extends State<PersonalAccount> {
  final Prefs _prefs = Prefs();
  var userImage = "";
  var userFirstName = "";
  var userPhone = "";
  var userGroupCode = "";
  var userRole = "";
  late bool loanModules;
  late bool membershipFee;
  late bool finesModule;
  late bool expensesModule;
  var userActiveInGroup = "";
  var loanID = "";
  String groupName = "";
  bool loadingTransactions = true;
  double availableCash = 0.0;
  double total_contribution = 0.0;
  double interest_paid_sofar = 0.0;
  double membership_fee = 0.0;
  double total_fines = 0.0;
  double total_repayed_loans = 0.0;
  double total_group_expenses = 0.0;
  double total_taken_loans = 0.0;
  int total_members = 0;
  double current_month_highest_contribution = 0.0;
  double current_month_average_contribution = 0.0;
  double interest_this_month = 0.0;

  double yourTotalUnPaidLoans = 0.0;
  double yourTotalUnPaidInterests = 0.0;
  double yourTotalUnPaidFines = 0.0;
  List<MainMenu> myMainMenus = [];
  List<String> transactionTypes = [];
  List<String> items = [];
  List<PersonalDashBoardData> allDashboardData = [];
  String dropDownValue = '';

  @override
  void initState() {
    super.initState();
    getLoggedUser();
  }

  void getGroupCode() {
    _prefs.getStringValuesSF('groupCode').then((groupCode) => {
          setState(() => {
                userGroupCode = groupCode!,
                _populateDashBoard(),
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
                buildMenus(),
              })
        });
  }

  void getLoggedUser() {
    _prefs.getLoggedUSer().then((user) => {
          setState(() => {
                userFirstName = user.fname,
                userImage = user.image,
                userPhone = user.phone,
                getClickedGroupDetails(),
              })
        });
  }

  void _populateDashBoard() {
    Webservice()
        .load(PersonalDashBoardData.all(userPhone, userGroupCode))
        .then((personaldashboarddata) => {
              if (mounted)
                setState(() {
                  allDashboardData = personaldashboarddata;
                  total_contribution =
                      double.parse(allDashboardData[0].total_contribution);
                  interest_paid_sofar =
                      double.parse(allDashboardData[0].interest_paid_so_far);
                  total_fines = double.parse(allDashboardData[0].total_fines);
                  total_repayed_loans =
                      double.parse(allDashboardData[0].total_repayed_loans);
                  total_taken_loans =
                      double.parse(allDashboardData[0].total_taken_loans);
                  interest_this_month =
                      double.parse(allDashboardData[0].interest_this_month);
                  yourTotalUnPaidFines =
                      double.parse(allDashboardData[0].yourTotalUnpaidFines);
                  yourTotalUnPaidInterests = double.parse(
                      allDashboardData[0].yourTotalUnpaidInterests);
                  yourTotalUnPaidLoans =
                      total_taken_loans - total_repayed_loans;

                  loadingTransactions = false;
                  buildMenus();
                })
            });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: priColorShade,
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: priColor,
          title: Text(
            loadingTransactions ? '' : "$userFirstName's Account",
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
        body: Card(
          child: Column(
            children: [
              Container(
                height: 80,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [secbgColor, secbgColor]),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 10.0, top: 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            width: 60.0,
                            height: 60.0,
                            decoration: BoxDecoration(
                              color: priAccentColor,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(.1),
                                    blurRadius: 2,
                                    spreadRadius: 1)
                              ],
                              border: Border.all(
                                width: 1.5,
                                color: Colors.white,
                              ),
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: GestureDetector(
                              child: CircleAvatar(
                                radius: 90,
                                backgroundColor: transparentColor,
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        "${urlRoot}profilepics/$userImage",
                                    fit: BoxFit.cover,
                                    width: 200,
                                    height: 200,
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(
                                      color: adminColor,
                                      strokeWidth: 1,
                                      backgroundColor: transparentColor,
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Image.asset("assets/images/blank.png"),
                                  ),
                                ),
                              ),
                              onTap: () {
                                Get.toNamed('/profile');
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 0,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Savings",
                                      style: mainBoldText(),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          forCurrency(total_contribution),
                                          style: mainBoldText(),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Container(
                                  color: adminColor,
                                  height: 50,
                                  width: 3,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Loan Balance",
                                      style: mainBoldText(),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          forCurrency(yourTotalUnPaidLoans),
                                          style: mainBoldText(),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Flexible(
              //   flex: 1,
              //   child: Container(
              //     padding: EdgeInsets.all(10),
              //     width: double.infinity,
              //     child: PieChart(PieChartData(
              //         centerSpaceRadius: 30,
              //         centerSpaceColor: Colors.yellow,
              //         borderData: FlBorderData(show: false),
              //         sections: [
              //           PieChartSectionData(value: 10, color: Colors.blue),
              //           PieChartSectionData(value: 10, color: Colors.orange),
              //           PieChartSectionData(value: 10, color: Colors.purple),
              //           PieChartSectionData(value: 20, color: Colors.amber),
              //           PieChartSectionData(value: 30, color: Colors.green)
              //         ])),
              //   ),
              // ),
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  //color: Colors.grey.shade100,
                  color: priColorShade,
                  child: ListView.builder(
                    itemCount: myMainMenus.length,
                    itemBuilder: _buildItemsForListView,
                    //padding: const EdgeInsets.all(2),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Get.to(() => const AddTransaction());
            },

            //label: const Text(''),

            backgroundColor: priColor,
            child: const Icon(
              Icons.add,
              color: secbgColor,
            )),
      ),
    );
  }

  Widget _buildItemsForListView(BuildContext context, int index) {
    return InkWell(
      child: Card(
        shadowColor: bgColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        margin: const EdgeInsets.fromLTRB(1, 2, 1, 2),
        borderOnForeground: false,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            children: [
              Column(
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
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          myMainMenus[index].title.toUpperCase(),
                          style: labelBlackText().copyWith(color: adminColor),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      myMainMenus[index].description,
                      style:
                          mainText().copyWith(color: greyColor, fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                            myMainMenus[index].position == 0 ||
                                    myMainMenus[index].position == 10
                                ? ''
                                : forCurrency(myMainMenus[index].value),
                            style: MainAccentText(),
                            textAlign: TextAlign.right),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Icon(
                    Icons.arrow_right,
                    color: adminColor,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        if (myMainMenus[index].position != 10) {
          Get.toNamed('/transactions', arguments: {
            'scope': 'personal',
            'tTypes': myMainMenus[index].title.toString(),
            'url':
                'alltransactions_bycatandperson.php?phone=$userPhone&position=${myMainMenus[index].position}&groupCode=$userGroupCode'
          });
          // Navigator.of(context).pushAndRemoveUntil(
          //     MaterialPageRoute(
          //         builder: (BuildContext context) => SpecificTransactions(
          //             scope: "personal",
          //             tType: TransactionType(
          //                 myMainMenus[index].title.toString(),
          //                 "alltransactions_bycatandperson.php?phone=$userPhone&position=${myMainMenus[index].position}&groupCode=$userGroupCode"))),
          //     (Route<dynamic> route) => true);
        } else {
          Get.toNamed('/pendingtransactions');
        }
      },
    );
  }

  void buildMenus() {
    myMainMenus.clear();
    MainMenu allTransactions = MainMenu(Icons.list_alt_outlined,
        'All Your Transactions', 'All your approved transactions', 0.0, 0);
    MainMenu allContributions = MainMenu(Icons.money, 'Your Contributions',
        'All your contributions', total_contribution, 1);
    MainMenu allLoansTaken = MainMenu(Icons.arrow_circle_down_sharp,
        'Loans You Took', 'All the loans you took', total_taken_loans, 2);
    MainMenu allRepaidLoan = MainMenu(Icons.backup_table, 'Loans You Repaid',
        'All the loans you repaid', total_repayed_loans, 3);
    MainMenu allPaidFines = MainMenu(Icons.check_circle, 'Fines You Paid',
        'All the fines you paid', total_fines, 4);
    MainMenu allPaidInterest = MainMenu(
        Icons.arrow_circle_up,
        'Interest You Paid',
        'All interest you paid to date',
        interest_paid_sofar,
        5);
    MainMenu allUnpaidLoans = MainMenu(Icons.description, 'Your Unpaid Loans',
        'All Loans you are yet to pay', yourTotalUnPaidLoans, 6);
    MainMenu allUnpaidInterest = MainMenu(
        Icons.assessment_rounded,
        'Your Unpaid Interests',
        'All Interests you are yet to pay',
        yourTotalUnPaidInterests,
        7);
    MainMenu allUnpaidFines = MainMenu(
        Icons.timelapse_sharp,
        'Your Unpaid Fines',
        'All Fines you are yet to pay',
        yourTotalUnPaidFines,
        8);
    MainMenu currentMonthInterest = MainMenu(
        Icons.arrow_circle_up_rounded,
        '${getCurrentMonth().substring(0, 1).toUpperCase()}${getCurrentMonth().substring(1).toLowerCase()}\'s Interest',
        'Interest you paid in ${getCurrentMonth().substring(0, 1).toUpperCase()}${getCurrentMonth().substring(1).toLowerCase()}',
        interest_this_month,
        9);
    MainMenu allPendingTransactions = MainMenu(
        Icons.edit,
        'Pending Transactions',
        'Yet to be approved, you can delete or edit',
        total_group_expenses,
        10);

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
    myMainMenus.add(allTransactions);
    myMainMenus.add(allContributions);
    myMainMenus.add(allPendingTransactions);
    myMainMenus.sort((a, b) => a.position.compareTo(b.position));
    _populateDashBoard();
  }
}
