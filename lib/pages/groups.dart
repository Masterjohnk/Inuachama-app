import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:inuachama/models/clickedgroup.dart';
import 'package:inuachama/models/group.dart';
import 'package:inuachama/util/configurations.dart';
import 'package:inuachama/util/responsive_manager.dart';
import 'package:inuachama/util/templates.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

late BuildContext con;
TextEditingController codeController = TextEditingController();
final Prefs _prefs = Prefs();

TextEditingController nameController = TextEditingController();
TextEditingController numberController = TextEditingController();
late ScaffoldMessengerState scaffoldMessenger;

class MyGroups extends StatefulWidget {
  const MyGroups({Key? key}) : super(key: key);

  @override
  MyGroupsState createState() => MyGroupsState();
}

class MyGroupsState extends State<MyGroups> {
  List<Group> groups = [];
  var userPhone = "";
  List<Group> allGroups = [];
  String query = "";
  String? _sortValue;
  bool loadingGroups = true;
  TextEditingController filterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getPhone();
  }

  void _populateGroups() {
    filterController.clear();
    groups.clear();
    allGroups.clear();
    _sortValue = null;
    Webservice()
        .load(Group.all("getgroups.php?phone=$userPhone"))
        .then((fetchedGroups) => {
              setState(() => {
                    allGroups = fetchedGroups,
                    groups = allGroups,
                    loadingGroups = false
                  })
            });
  }

  void getPhone() {
    _prefs.getStringValuesSF('phone').then((phone) => {
          setState(() => {
                userPhone = phone!,
                _populateGroups(),
              })
        });
  }

  void _orderByGroups(key) {
    setState(() {
      if (key.toString().compareTo("Group Name ") == 0) {
        groups.sort((a, b) => a.groupName.compareTo(b.groupName));
      } else if (key.toString().compareTo("Group Name Desc") == 0) {
        groups.sort((b, a) => a.groupName.compareTo(b.groupName));
      }
    });
  }

  Widget _buildItemsForListView(BuildContext context, int index) {
    return InkWell(
      child: Card(
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
                        radius: 30,
                        backgroundColor: transparentColor,
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl:
                                "${urlRoot}chamaimages/${groups[index].groupImage}",
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(
                              color: adminColor,
                              strokeWidth: 2,
                              backgroundColor: transparentColor,
                            ),

                            // You can use LinearProgressIndicator or CircularProgressIndicator instead

                            errorWidget: (context, url, error) {
                              return Image.asset("assets/images/logo.png");
                            },
                          ),
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
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            groups[index].groupName.toString().toUpperCase(),
                            style: labelPriSmallColorText(),
                          ),
                        ),
                        Icon(
                            groups[index]
                                        .groupStatus
                                        .toString()
                                        .compareTo('Active') ==
                                    0
                                ? Icons.check_circle
                                : Icons.pause_circle_filled,
                            color: groups[index]
                                        .groupStatus
                                        .toString()
                                        .compareTo('Active') ==
                                    0
                                ? priColor
                                : Colors.red)
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'GROUP CODE: ${groups[index].groupCode}',
                          style: labelPriSmallColorText(),
                        ),
                        Text(
                          int.parse(groups[index].groupMembers.toString()) != 0
                              ? int.parse(groups[index]
                                          .groupMembers
                                          .toString()) >
                                      1
                                  ? '${groups[index].groupMembers} MEMBERS'
                                  : '${groups[index].groupMembers} MEMBER'
                              : ' NO MEMBER',
                          style: mainText(),
                        )
                      ],
                    ),
                    if (groups[index]
                            .groupStatus
                            .toString()
                            .compareTo('Active') !=
                        0)
                      Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            groups[index].groupStatusReason,
                            style: mainText(),
                          ),
                        ],
                      ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Since: ${DateFormatter().getVerboseDateTimeRepresentation(myDateFormartted(groups[index].groupCreateDate))}",
                      style: mainText(),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        if (groups[index].userActive.toString().compareTo('0') == 0) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Row(children: [
                  Icon(Icons.error, color: priColor),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Group Access",
                    style: mainAccentText(),
                    textAlign: TextAlign.center,
                  ),
                ]),
                content: Text(
                  "You have been deactivated from the group. Please contact your Group Admin",
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
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          ClickedGroup clickedGroup;
          clickedGroup = ClickedGroup(
              groups[index].groupCode,
              groups[index].groupName,
              groups[index].userRole,
              groups[index].userActive,
              groups[index].groupImage,
              groups[index].alertsToAll,
              groups[index].loansModule,
              groups[index].expensesModule,
              groups[index].membershipFeeModule,
              groups[index].finesModule,
              groups[index].adminRecords,
              groups[index].accessReport,
              groups[index].contributionEvents,
              groups[index].downloadReport,
              groups[index].shareCapital,
              groups[index].incomeModule);

          if (groups[index].groupStatus.toString().compareTo('Active') == 0) {
            usageStats(groups[index].groupCode, userPhone);
            _prefs
                .saveClickedGroup(clickedGroup)
                .then((done) => {Get.to('/dashboard')});
          } else {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return WillPopScope(
                    onWillPop: () async => false,
                    child: AlertDialog(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cancel_rounded,
                            color: priColor,
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(
                            "Group Deactivated",
                            style: mainAccentText(),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "The group has been deactivated for non payment subscription fees.",
                            style: mainText(),
                          )
                        ],
                      ),
                      actions: <Widget>[
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              actionButton('Ok', Icons.cancel, () {
                                Navigator.pop(context);
                              }),
                            ])
                      ],
                    ),
                  );
                });
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    con = context;
    scaffoldMessenger = ScaffoldMessenger.of(context);
    return WillPopScope(
      onWillPop: () => showExitPopup(context),
      child: Scaffold(
          backgroundColor: priColorShade,
          appBar: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: priColor,
            title: Text(
              "Your Groups (${groups.length})",
              style: appBarText(),
              textAlign: TextAlign.center,
            ),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                onPressed: () {
                  _populateGroups();
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
          ),
          body: ResponsiveHelper(
            mobile: Column(
              children: [
                searchWidget(),
                sortOptions(),
                groupsList(),
                groupOptions(),
              ],
            ),
            desktop: Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          searchWidget(),
                          sortOptions(),
                          groupsList(),
                        ],
                      )),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    color: priAccentColor,
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          groupOptions(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Widget groupOptions() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          children: [
            Card(
              elevation: 1.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      'New Here? Welcome',
                      style: labelPriColorText(),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Join An Existing Chama Group using the Group Code you received from your Group Leader - the person who invited you.',
                      style: mainText(),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        joinGroupPop(context);
                      },
                      // ignore: sort_child_properties_last
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.group_add_outlined),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Join A Group',
                            style: labelWhiteSmallerText(),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: priColor,
                        minimumSize: const Size(double.infinity, 40),
                        elevation: 1,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Card(
              //elevation: 1.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      'Create a new Chama Group and invite members to join using the Group Code that will be generated. - 7 day trial period, see how this works ;-)',
                      style: mainText(),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        addGroupPopUP(context);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: priColor,
                        minimumSize: const Size(double.infinity, 40),
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_sharp),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Create New Group',
                            style: labelWhiteSmallerText(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget groupsList() {
    return loadingGroups
        ? Center(
            child: CircularProgressIndicator(
              //  color: priAccentColor,
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(priColor),
            ),
          )
        : groups.isEmpty
            ? emptyListView("You have not created or joined any group yet..")
            : Expanded(
                child: ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: _buildItemsForListView,
                ),
              );
  }

  Widget searchWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 5, 24, 5),
      child: TextField(
          autofocus: false,
          controller: filterController,
          style: mainText(),
          decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                color: priColor,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: inactiveColor!),
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
              hintText: ' Group code or Group Name',
              hintStyle: hiText()),
          onChanged: filterAction),
    );
  }

  void filterAction(string) {
    setState(() {
      groups = allGroups
          .where((u) => (u.groupName
                  .toString()
                  .toLowerCase()
                  .contains(string.toLowerCase()) ||
              u.groupCode
                  .toString()
                  .toLowerCase()
                  .contains(string.toLowerCase())))
          .toList();
    });
    //});
  }

  Widget sortOptions() {
    return DropdownButton<String>(
      focusColor: Colors.white,
      value: _sortValue,
      elevation: 1,
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.black,
      items: <String>[
        'Group Name',
        'Group Name Desc',
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: labelPriSmallColorText(),
          ),
        );
      }).toList(),
      hint: Text(
        "Specify Order Criteria",
        style: labelPriSmallColorText(),
      ),
      onChanged: (String? value) {
        setState(() {
          _sortValue = value;
          _orderByGroups(_sortValue);
        });
      },
    );
  }

  Future<void> joinGroupPop(BuildContext context) async {
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
                "Join Group",
                style: mainAccentText(),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildCodeTextField(Icons.receipt_rounded, 'Group Code', false,
                      TextInputType.number, codeController, 1, true),
                ],
              ),
              actions: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      actionButton('Cancel', Icons.cancel, () {
                        Navigator.pop(context);
                      }),
                      actionButton('Join', Icons.group_add_outlined, () {
                        if (codeController.text.isEmpty ||
                            codeController.text.length < 5) {
                          showSnackBar("Provide the 5-digit group code");
                          return;
                        } else {
                          DialogBuilder(context).showLoadingIndicator(
                              "Please wait as we add you to the group..",
                              "Joining Group");
                          joinGroup();
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

  Future<void> addGroupPopUP(BuildContext context) async {
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
                "Create Group",
                style: mainAccentText(),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildCodeTextField(Icons.group_work_sharp, 'Group Name',
                      false, TextInputType.text, nameController, 1, true),
                  buildTextField(Icons.group_sharp, 'Number of members', false,
                      TextInputType.number, numberController, 1)
                ],
              ),
              actions: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      actionButton('Cancel', Icons.cancel, () {
                        Navigator.pop(context);
                      }),
                      actionButton('Create', Icons.check_circle, () {
                        if (nameController.text.isEmpty) {
                          showSnackBar("Provide a name for the group");
                          return;
                        } else if (!isNumber(numberController.text)) {
                          showSnackBar(
                              "Group size cant be empty or less than 2");
                          return;
                        } else {
                          DialogBuilder(context).showLoadingIndicator(
                              "Please wait as we create the group..", "Group");
                          createGroup();
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

  void joinGroup() {
    var client = http.Client();
    client.post(Uri.parse("${urlRoot}joingroup.php"), body: {
      "phone": userPhone,
      "groupCode": codeController.text.trim(),
    }).then((response) {
      DialogBuilder(context).hideOpenDialog();

      client.close();
      if (mounted && response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);

        //if (jsonResponse['code'] == 1 || jsonResponse['code'] == 0) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                "Join Group",
                style: mainAccentText(),
                textAlign: TextAlign.center,
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
                    codeController.text = "";
                    _populateGroups();
                    Navigator.pop(context);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        //}
      }
    });
  }

  void createGroup() {
    var client = http.Client();
    client.post(Uri.parse("${urlRoot}creategroup.php"), body: {
      "groupCreator": userPhone,
      "groupName": nameController.text.trim(),
      "groupSize": numberController.text.trim(),
    }).then((response) {
      DialogBuilder(context).hideOpenDialog();
      client.close();
      if (mounted && response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['code'] == 0 || jsonResponse['code'] == 3) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  "Group",
                  style: mainAccentText(),
                  textAlign: TextAlign.center,
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
                      nameController.text = '';
                      numberController.text = '';
                      Navigator.pop(context);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  "Group",
                  style: mainAccentText(),
                  textAlign: TextAlign.center,
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
                      nameController.text = '';
                      numberController.text = '';
                      _populateGroups();
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

  void usageStats(String groupCode, String phone) {
    String url = "${urlRoot}usageStatistics.php";
    var client = http.Client();
    client.post(Uri.parse(url), body: {
      "groupCode": groupCode,
      "userPhone": phone,
    }).then((response) {
      client.close();
    }).catchError((onError) {
      client.close();
    });
  }
}
