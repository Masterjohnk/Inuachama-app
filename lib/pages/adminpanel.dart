import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:inuachama/pages/membermanagement.dart';
import 'package:inuachama/pages/transactionmanagement.dart';
import 'package:inuachama/util/configurations.dart';
import 'package:inuachama/util/templates.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

DateTime currentDate = DateTime.now();
DateTime deactivateDate = DateTime.now();
String selectedMember = '';
var myMembers = {};
List<String> members = [];
List<String> allMembers = [];
bool loadingMember = true;

enum MessageType { push, sms }

List<String> adminMenu = [
  'Group Settings',
  'Membership Management',
  'Transaction Management',
  'Send Alerts/SMS',
  'Group Billing',
  'Add Contribution Events'
];
List<String> adminMenuDescription = [
  'Configure group options',
  'Delete or Approve Members',
  'Approve Update or Transactions',
  'Send alerts or SMSs to members',
  'Pay and manage group billing',
  'Events for contributions eg. death'
];
int charLength = 0;
List<IconData> adminMenuIcons = [
  Icons.settings,
  Icons.supervised_user_circle,
  Icons.list_alt_rounded,
  Icons.add_alert_rounded,
  Icons.money,
  Icons.event,
];
final Prefs _prefs = Prefs();
String userGroupCode = "";
String userPhone = "";
String userRole = "1";
bool isContributionEvents = false;
MessageType messageOption = MessageType.push;

class AdminPanel extends StatefulWidget {
  const AdminPanel({Key? key}) : super(key: key);

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  @override
  void initState() {
    deactivateDate.add(const Duration(days: 7));
    super.initState();
    getPhone();
    getRole();
  }

  void getPhone() {
    _prefs.getStringValuesSF('phone').then((phone) => {
          setState(() => {
                userPhone = phone!,
                getClickedGroupDetails(),
              }),
        });
  }

  void getRole() {
    _prefs.getStringValuesSF('role').then((role) => {
          setState(() => {
                userRole = role!,
              }),
        });
  }

  void getClickedGroupDetails() {
    _prefs.getClickedGroup().then((group) => {
          setState(() => {
                userGroupCode = group.groupCode,
                isContributionEvents = group.isEventsContribution,
                getMembers(),
              }),
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: priColorShade,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: priColor,
        title: Text(
          'Administration Panel',
          style: appBarText(),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount:
            isContributionEvents ? adminMenu.length : adminMenu.length - 1,
        itemBuilder: _buildAdminMenuOption,
        padding: const EdgeInsets.all(5),
      ),
    );
  }

  void submitPost(BuildContext context) {
    var client = http.Client();
    client.post(Uri.parse("${urlRoot}createpost.php"), body: {
      "phone": userPhone,
      "description": commentController.text.trim(),
      "title": codeController.text.trim(),
      "groupCode": userGroupCode,
      "category": "Admin Broadcast",
      "type": messageOption
          .toString()
          .substring(messageOption.toString().indexOf('.') + 1),
    }).then((response) {
      DialogBuilder(context).hideOpenDialog();

      client.close();
      if (response.statusCode == 200) {
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
                      "Admin Messaging",
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

  void submitEvent(BuildContext context) {
    var client = http.Client();
    client.post(Uri.parse("${urlRoot}contributionEvent.php"), body: {
      "creator": userPhone,
      "memberLinked": myMembers[selectedMember] ?? '',
      "description": commentController.text.trim(),
      "title": codeController.text.trim(),
      "groupCode": userGroupCode,
      "category": "createContributionEvent",
      "deactivateDate": deactivateDate.toString(),
    }).then((response) {
      DialogBuilder(context).hideOpenDialog();

      client.close();
      if (response.statusCode == 200) {
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
                      "Event Creation",
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

  Widget _buildAdminMenuOption(BuildContext context, int index) {
    return InkWell(
        child: Card(
          margin: const EdgeInsets.fromLTRB(5, 2, 5, 2),
          shadowColor: priColor,
          borderOnForeground: true,
          elevation: 1.0,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(1.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        adminMenuIcons[index],
                        color: priColor,
                        size: 30,
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      adminMenu[index].toUpperCase(),
                      style:
                          labelPriSmallColorText().copyWith(color: adminColor),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      adminMenuDescription[index],
                      style: mainText(),
                      softWrap: true,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(1.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.arrow_right,
                              color: priColor,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          switch (index) {
            case 0:
              {
                if (userRole.compareTo("2") != 0) {
                  Get.toNamed('/groupsettings');
                } else {
                  showSnackBar(
                      "You do not the necessary rights to accesses this module");
                }
              }
              break;
            case 1:
              {
                if (userRole.compareTo("2") != 0) {
                  Get.toNamed('/membershipmanagement');
                } else {
                  showSnackBar(
                    "You do not the necessary rights to accesses this module",
                  );
                }
              }
              break;
            case 2:
              {
                Get.toNamed('/transactionmanagement');
              }
              break;
            case 3:
              {
                if (userRole.compareTo("2") != 0) {
                  addAdminMsgPopUP(context);
                } else {
                  showSnackBar(
                      "You do not the necessary rights to accesses this module");
                }
              }
              break;

            case 4:
              {
                if (userRole.compareTo("2") != 0) {
                  Get.toNamed('/groupbilling');
                } else {
                  showSnackBar(
                      "You do not the necessary rights to accesses this module");
                }
              }
              break;
            case 5:
              {
                addEntryPopUP(context);
              }
              break;
          }
        });
  }

  Future<void> addEntryPopUP(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: Text(
                "Add Event",
                style: mainAccentText(),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      actionButton('End Date', Icons.calendar_today_sharp,
                          () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: currentDate,
                          firstDate: currentDate,
                          lastDate: currentDate.add(const Duration(days: 90)),
                        );
                        if (picked != null && picked != deactivateDate) {
                          setState(() {
                            deactivateDate = picked;
                          });
                        }
                      }, 110),
                      const SizedBox(
                        width: 5,
                      ),
                      Flexible(
                        child: Text(myFormattedDate(deactivateDate.toString())),
                      )
                    ],
                  ),
                  Row(children: [
                    actionButton('Member', Icons.group, () {
                      //_lastDate(context);
                    }, 105),
                    const SizedBox(
                      width: 5,
                    ),
                    Flexible(
                      child: DropdownButton(
                        value: selectedMember,
                        hint: Text(
                          "Select Member",
                          style: mainText(),
                          textAlign: TextAlign.center,
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: members.map((String members) {
                          return DropdownMenuItem(
                              value: members,
                              child: Text(
                                members,
                                style: mainText(),
                              ));
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedMember = newValue!;
                          });
                        },
                      ),
                    ),
                  ]),
                  buildCodeTextField(Icons.receipt_rounded, 'Event', false,
                      TextInputType.text, codeController, 1, true),
                  // buildTextFieldAction(Icons.comment, 'Message', false,
                  //     TextInputType.text, commentController, 5),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextField(
                        autofocus: false,
                        maxLines: 2,
                        style: mainText(),
                        controller: commentController,
                        obscureText: false,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.comment,
                              size: 20,
                              color: priColor,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: inactiveColor!),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: priColor),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(0),
                            hintText: 'Description',
                            hintStyle: hiText()),
                        onChanged: (String value) {
                          setState(() {
                            charLength = value.length;
                          });
                        }),
                  ),
                  Text("Characters $charLength"),
                ],
              ),
              actions: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      actionButton('Cancel', Icons.cancel, () {
                        Navigator.pop(context);
                      }),
                      actionButton('Add', Icons.add, () {
                        if (codeController.text.isEmpty ||
                            codeController.text.length < 3) {
                          showSnackBar("Provide event title.");
                          return;
                        } else {
                          DialogBuilder(context).showLoadingIndicator(
                              "Please wait as we create the event ..",
                              "Creating...");
                          submitEvent(context);
                        }
                      })
                    ])
              ],
            ),
          );
        });
      },
    );
  }

  void getMembers() {
    members.clear();
    allMembers.clear();
    myMembers.clear();
    var client = http.Client();
    client.post(Uri.parse("${urlRoot}getmembers.php?groupCode=$userGroupCode"),
        body: {}).then((response) {
      client.close();
      if (mounted && response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        jsonResponse.forEach((s) {
          String memberName = s['fname'] + " " + s['lname'] + '\n' + s['phone'];
          allMembers.add(memberName);
          myMembers[memberName] = s['phone'];
        });
        setState(() {
          loadingMembers = false;
          members = allMembers;
          members.sort((a, b) => a.compareTo(b));
          selectedMember = allMembers[0];
        });
      }
    });
  }

  Future<void> addAdminMsgPopUP(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: Text(
                "Send Message",
                style: mainAccentText(),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    horizontalTitleGap: 1,
                    title: const Text('Push Notification'),
                    leading: Radio(
                      value: MessageType.push,
                      groupValue: messageOption,
                      onChanged: (MessageType? value) {
                        setState(() {
                          messageOption = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    minVerticalPadding: 1,
                    horizontalTitleGap: 1,
                    title: const Text('SMS'),
                    leading: Radio(
                      value: MessageType.sms,
                      groupValue: messageOption,
                      onChanged: (MessageType? value) {
                        setState(() {
                          messageOption = value!;
                        });
                      },
                    ),
                  ),
                  buildCodeTextField(Icons.receipt_rounded, 'Subject', false,
                      TextInputType.text, codeController, 1, true),
                  // buildTextFieldAction(Icons.comment, 'Message', false,
                  //     TextInputType.text, commentController, 5),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextField(
                        autofocus: false,
                        maxLines: 5,
                        style: mainText(),
                        controller: commentController,
                        obscureText: false,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.comment,
                              size: 20,
                              color: priColor,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: inactiveColor!),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: priColor),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(0),
                            hintText: 'Message',
                            hintStyle: hiText()),
                        onChanged: (String value) {
                          setState(() {
                            charLength = value.length;
                          });
                        }),
                  ),
                  Text("Characters $charLength"),
                ],
              ),
              actions: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      actionButton('Cancel', Icons.cancel, () {
                        Navigator.pop(context);
                      }),
                      actionButton('Send', Icons.check_circle, () {
                        if (codeController.text.isEmpty ||
                            codeController.text.length < 3) {
                          showSnackBar(
                              "Provide a post title and the message to be posted");
                          return;
                        } else {
                          DialogBuilder(context).showLoadingIndicator(
                              "Please wait as we post the message ..",
                              "Posting...");
                          submitPost(context);
                        }
                      })
                    ])
              ],
            ),
          );
        });
      },
    );
  }
}
