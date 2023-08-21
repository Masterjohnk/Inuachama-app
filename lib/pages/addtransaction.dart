import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:inuachama/models/members.dart';
import 'package:inuachama/util/configurations.dart';
import 'package:inuachama/util/templates.dart';
import 'package:http/http.dart' as http;

int _selectedIndex = 0;
List<Member> members = [];
List<Member> allMembers = [];
bool loadingMembers = true;
List<String> transactionTypes = [];
List<String> groupEvents = [];
List<String> events = [];
List<String> userLoanIDS = [];
List<String> items = [];

List<String> loanIDs = [];
List<Member> mems = [];
List<Member> allMems = [];
String dropDownValue = '';
String selectedEvent = '';
String selectedMember = '';
String dropDownLoanID = '';
var userImage = "";
var userRole = "";
var userPhone = "";
var userGroupCode = "";
late bool loanModules;
late bool membershipFee;
late bool finesModule;
late bool expensesModule;
late bool adminRecords;
late bool contributionEvents;
late bool postForOthers = false;
bool getMpesaCode = false;
var userActiveInGroup = "";
var loanID = "";
String groupName = "";

late ScaffoldMessengerState scaffoldMessenger;
var userFirstName, userLastName;

class AddTransaction extends StatefulWidget {
  const AddTransaction({Key? key}) : super(key: key);

  @override
  _AddTransactionState createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  TextEditingController filterController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  final Prefs _prefs = Prefs();

  @override
  void initState() {
    super.initState();
    MpesaCode();
    getLoggedUser();
  }

  @override
  void dispose() {
    events.clear();
    transactionTypes.clear();
    super.dispose();
  }

  void getLoggedUser() {
    _prefs.getLoggedUSer().then((user) => {
          setState(() => {
                userImage = user.image,
                userPhone = user.phone,
                userFirstName = user.fname,
                userLastName = user.lname,
                getClickedGroupDetails(),
                getLoanIDS(),
                // getContributionEvents(),
              })
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
                getTransactionTypes(),
                //  getContributionEvents(),

                //_populateDashBoard(),
              }),
          _getMembers(),
        });
  }

  @override
  Widget build(BuildContext context) {
    scaffoldMessenger = ScaffoldMessenger.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: priColor,
        title: Text(
          "Add Transaction",
          style: appBarText(),
        ),
        centerTitle: true,
      ),
      body: addTrans(),
    );
  }

  Widget addTrans() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 1, 20, 1),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (adminRecords && userRole.compareTo('1') == 0 ||
                  userRole.compareTo('2') == 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: postForOthers,
                      onChanged: (bool? value) {
                        setState(() {
                          postForOthers = value ?? false;
                        });
                      },
                    ),
                    const Text('Post for other'),
                  ],
                ),
              if (postForOthers)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 5, 24, 5),
                      child: Column(
                        children: [
                          TextField(
                              controller: filterController,
                              style: mainText(),
                              decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: priColor,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: inactiveColor!),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(15.0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: priColor),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(15.0),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.all(0),
                                  hintText: 'Member ID or Phone',
                                  hintStyle: hiText()),
                              onChanged: filterAction),
                        ],
                      ),
                    ),
                    if (!loadingMembers)
                      SizedBox(
                        height: 200.0, // Change as per your requirement
                        // Change as per your requirement
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: mems.length,
                          itemBuilder: _buildItemsForMemberResults,
                        ),
                      ),
                  ],
                ),
              DropdownButton(
                value: dropDownValue,
                hint: Text(
                  "Select Transaction Type",
                  style: mainText(),
                  textAlign: TextAlign.center,
                ),
                icon: const Icon(Icons.keyboard_arrow_down),
                items: items.map((String trans) {
                  return DropdownMenuItem(
                      value: trans,
                      child: Text(
                        trans,
                        style: mainText(),
                      ));
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    dropDownValue = newValue!;
                  });
                },
              ),
              if (dropDownValue.compareTo('Loan Payment') == 0 ||
                  dropDownValue.compareTo('Interest Payment') == 0)
                DropdownButton(
                  value: dropDownLoanID,
                  hint: Text(
                    "Select LoanID",
                    style: mainText(),
                    textAlign: TextAlign.center,
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: loanIDs.map((String loanIDs) {
                    return DropdownMenuItem(
                        value: loanIDs,
                        child: Text(
                          loanIDs,
                          style: mainText(),
                        ));
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropDownLoanID = newValue!;
                    });
                  },
                ),
              if (contributionEvents &&
                  dropDownValue.compareTo('Contribution Payment') == 0)
                DropdownButton(
                  value: selectedEvent,
                  hint: Text(
                    "Select Event",
                    style: mainText(),
                    textAlign: TextAlign.center,
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: events.map((String elements) {
                    return DropdownMenuItem(
                        value: elements,
                        child: Text(
                          elements,
                          style: mainText(),
                        ));
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedEvent = newValue!;
                    });
                  },
                ),
              buildTextField(
                  Icons.money,
                  'Amount',
                  false,
                  const TextInputType.numberWithOptions(
                      signed: false, decimal: true),
                  amountController),
              buildCodeTextField(Icons.receipt_rounded, 'Transaction Code',
                  false, TextInputType.text, codeController, 1, true),
              buildTextField(Icons.comment, 'Comments', false,
                  TextInputType.text, commentController, 3),
              Text('Avoid comments as information provided is mostly enough',
                  style: verysmallText(), textAlign: TextAlign.center),
              mySpace(10),
              actionButton("Submit", Icons.save, submitTransaction)
            ],
          ),
        ),
      ),
    );
  }

  void filterAction(string) {
    setState(() {
      mems = allMems
          .where((u) => (u.fname
                  .toString()
                  .toLowerCase()
                  .contains(string.toLowerCase()) ||
              u.lname.toString().toLowerCase().contains(string.toLowerCase()) ||
              u.memberID
                  .toString()
                  .toLowerCase()
                  .contains(string.toLowerCase()) ||
              u.phone.toString().toLowerCase().contains(string.toLowerCase()) ||
              u.memberID
                  .toString()
                  .toLowerCase()
                  .contains(string.toLowerCase())))
          .toList();
    });
    //});
  }

  void _getMembers() {
    mems.clear();
    allMems.clear();
    Webservice().load(Member.getAllMembers(userGroupCode)).then((mem) => {
          setState(() => {
                allMems = mem,
                mems = allMems,
                loadingMembers = false,
              })
        });
  }

  Widget _buildItemsForMemberResults(BuildContext context, int index) {
    return InkWell(
      child: Card(
        color: _selectedIndex != null && _selectedIndex == index
            ? adminColor
            : Colors.white,
        margin: const EdgeInsets.fromLTRB(5, 2, 5, 2),
        shadowColor: priColor,
        borderOnForeground: true,
        elevation: 1.0,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              Column(
                children: <Widget>[
                  GestureDetector(
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: priAccentColor,
                        child: ClipOval(
                          child: CachedNetworkImage(
                              imageUrl:
                                  "${urlRoot}profilepics/" + mems[index].image,
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(
                                    color: adminColor,
                                    strokeWidth: 1,
                                  ),

                              // You can use LinearProgressIndicator or CircularProgressIndicator instead

                              errorWidget: (context, url, error) {
                                return Image.asset("assets/images/blank.png");
                              }),
                        ),

                        //backgroundColor: Colors.transparent,
                      ),
                      onTap: () {}),
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      mems[index].fname + " " + mems[index].lname,
                      style: labelPriSmallColorText(),
                    ),
                    if (mems[index].memberID.toString().isNotEmpty)
                      Text(
                        'Member ID: ' + mems[index].memberID,
                        style: mainText(),
                      ),
                    Text(
                      mems[index].phone,
                      style: mainText(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        //   if (transactions[index].isPaid.toString().compareTo('0') == 0 &&
        //       scopeAccess.compareTo('personal') == 0) {
        //     mpesaPaymentCode(context, transactions[index].t_id);
        setState(() {
          _selectedIndex = index;
          userFirstName = mems[index].fname;
          userLastName = mems[index].lname;
        });
        getLoanIDS(mems[index].phone);
        if (dropDownValue.toString().compareTo('Loan Request') == 0) {
          loanID = getLoanID(userFirstName, userLastName);
        }
      },
    );
  }

  void submitTransaction() {
    if (amountController.text.isEmpty) {
      showSnackBar("Specify the amount");

      return;
    } else {
      DialogBuilder(context).showLoadingIndicator(
          "Please wait as we add the transaction..", "Transaction");
      if (dropDownValue.toString().compareTo('Loan Request') == 0) {
        loanID = getLoanID(userFirstName, userLastName);
      } else if (dropDownValue.toString().compareTo('Loan Payment') == 0 ||
          dropDownValue.toString().compareTo('Interest Payment') == 0) {
        loanID = dropDownLoanID;
      } else {
        loanID = "";
      }
      var client = http.Client();
      client.post(Uri.parse("${urlRoot}createloantransaction.php"), body: {
        "for": postForOthers ? mems[_selectedIndex].phone : userPhone,
        "createdby": userPhone,
        "amount": amountController.text.trim(),
        "type": dropDownValue,
        "contributionEvent": selectedEvent.toString(),
        "description": commentController.text.trim(),
        "othernumber": userPhone,
        "code": getMpesaCode && codeController.text.trim().length > 8
            ? codeController.text.trim().substring(0, 10)
            : codeController.text.trim(),
        "loanid": loanID,
        "groupCode": userGroupCode,
        "guarantor": " ",
        "guarantor_approval": "0",
        "guaranteed_amount": "0",
      }).then((response) {
        DialogBuilder(context).hideOpenDialog();

        client.close();
        if (mounted && response.statusCode == 200) {
          var jsonResponse = json.decode(response.body);
          if (jsonResponse['code'] == 1 || jsonResponse['code'] == 0) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Row(
                    children: [
                      Icon(
                          jsonResponse['code'] == 1
                              ? Icons.check_circle
                              : Icons.info,
                          color: priColor),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Transaction",
                        style: mainAccentText(),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  content: Text(
                    jsonResponse['message'],
                    style: mainText(),
                    textAlign: TextAlign.center,
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text(
                        "Ok",
                        style: mainAccentText(),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        }
      });
    }
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
          selectedEvent = groupEvents[0];
        });
      }
    });
  }

  void getLoanIDS([phone]) {
    var client = http.Client();
    phone =
        phone.toString().isEmpty || postForOthers == false ? userPhone : phone;
    client.post(
        Uri.parse(
            '${urlRoot}getuserLoanIDs.php?phone=$phone&groupCode=$userGroupCode'),
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
    //getMembers();
  }
}
