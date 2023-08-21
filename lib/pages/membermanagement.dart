import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:inuachama/models/members.dart';
import 'package:inuachama/util/configurations.dart';
import 'package:inuachama/util/templates.dart';
import 'package:http/http.dart' as http;

late ScaffoldMessengerState scaffoldMessenger;
TextEditingController fnameController = TextEditingController();
TextEditingController snameController = TextEditingController();
bool loadingMembers = true;
late BuildContext con;
bool editName = false;
int clickedIndex = -1;

class MemberManagement extends StatefulWidget {
  const MemberManagement() : super();

  @override
  createState() => MemberManagementState();
}

enum InterestRate { compoundInterest, simpleInterest }

class MemberManagementState extends State<MemberManagement> {
  List<Member> members = [];
  List<Member> allMembers = [];
  String query = "";
  String? _sortValue;
  final Prefs _prefs = Prefs();
  bool loadingMembers = true;
  var userGroupCode = "";
  var userPhone = "";

  //String _interestRate = "";

  TextEditingController filterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getLoggedUser();
  }

  void getGroupCode() {
    _prefs.getStringValuesSF('groupCode').then((groupCode) => {
          setState(() => {
                userGroupCode = groupCode!,
                _populateMembers(),
              })
        });
  }

  void getLoggedUser() {
    _prefs.getLoggedUSer().then((user) => {
          setState(() => {
                userPhone = user.phone,
                getGroupCode(),
              })
        });
  }

  void _populateMembers() {
    //getGroupCode();
    filterController.clear();
    members.clear();
    allMembers.clear();
    _sortValue = null;
    Webservice().load(Member.getAllMembers(userGroupCode)).then((mems) => {
          setState(() => {
                allMembers = mems,
                members = allMembers,
                loadingMembers = false,
                members.removeWhere((element) =>
                    element.phone.toString().compareTo(userPhone) == 0)
              })
        });
  }

  void _orderByMembers(key) {
    setState(() {
      if (key.toString().compareTo("First Name") == 0) {
        members.sort((a, b) => a.fname.compareTo(b.fname));
      } else if (key.toString().compareTo("First Name Desc") == 0) {
        members.sort((b, a) => a.fname.compareTo(b.fname));
      } else if (key.toString().compareTo("Date Created") == 0) {
        members.sort((a, b) => a.joinDate.compareTo(b.joinDate));
      } else if (key.toString().compareTo("Date Created Desc") == 0) {
        members.sort((b, a) => a.joinDate.compareTo(b.joinDate));
      } else if (key.toString().compareTo("Email") == 0) {
        members.sort((a, b) => a.email.compareTo(b.email));
      } else if (key.toString().compareTo("Email Desc") == 0) {
        members.sort((b, a) => a.email.compareTo(b.email));
      }
    });
  }

  Widget _buildItemsForListView(BuildContext context, int index) {
    return Card(
      margin: const EdgeInsets.fromLTRB(5, 2, 5, 2),
      shadowColor: priColor,
      borderOnForeground: true,
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            Column(
              children: <Widget>[
                GestureDetector(
                    child: ClipOval(
                      child: CachedNetworkImage(
                          imageUrl:
                              "${urlRoot}profilepics/" + members[index].image,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
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
                    onTap: () {}),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text.rich(
                        TextSpan(
                          style: mainText(),
                          children: [
                            WidgetSpan(
                              child: Icon(
                                Icons.account_circle_outlined,
                                color: priColor,
                                size: 20,
                              ),
                            ),
                            TextSpan(
                              text: "${" " + members[index].fname} " +
                                  members[index].lname,
                              style: labelPriSmallColorText(),
                            )
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(editName ? Icons.edit_off : Icons.edit),
                        color: priColor,
                        onPressed: () {
                          setState(() {
                            clickedIndex = index;
                            editName = !editName;
                            fnameController.text = members[index].fname;
                            snameController.text = members[index].lname;
                          });
                        },
                      )
                    ],
                  ),
                  Visibility(
                    visible: editName && index == clickedIndex,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                      child: Card(
                        child: Column(
                          children: [
                            buildTextField(
                                Icons.account_box_outlined,
                                'First Name',
                                false,
                                TextInputType.text,
                                fnameController,
                                1),
                            buildTextField(
                                Icons.account_box_outlined,
                                'Second Name',
                                false,
                                TextInputType.text,
                                snameController,
                                1),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  actionButton('Cancel', Icons.cancel, () {
                                    setState(() {
                                      editName = false;
                                    });
                                  }),
                                  actionButton('Update', Icons.check_circle,
                                      () {
                                    if (fnameController.text.isEmpty ||
                                        fnameController.text.length < 3 ||
                                        snameController.text.isEmpty ||
                                        snameController.text.length < 3) {
                                      showSnackBar(
                                          "Provide valid First Name and Second Name");
                                      return;
                                    } else {
                                      DialogBuilder(context).showLoadingIndicator(
                                          "Please wait as we update member details ..",
                                          "Updating...");
                                      submitNameEdits(members[index].phone);
                                    }
                                  })
                                ]),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      style: mainText(),
                      children: [
                        WidgetSpan(
                          child: Icon(
                            Icons.card_membership_sharp,
                            color: priColor,
                            size: 20,
                          ),
                        ),
                        TextSpan(
                          text: " " + members[index].title,
                          style: mainText(),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  if (members[index].memberID.toString().isNotEmpty)
                    Text.rich(
                      TextSpan(
                        style: mainText(),
                        children: [
                          WidgetSpan(
                            child: Icon(
                              Icons.admin_panel_settings_rounded,
                              color: priColor,
                              size: 20,
                            ),
                          ),
                          TextSpan(
                            text: "Member ID " + members[index].memberID,
                            style: mainText(),
                          )
                        ],
                      ),
                    ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text.rich(
                    TextSpan(
                      style: mainText(),
                      children: [
                        WidgetSpan(
                          child: Icon(
                            Icons.phone_android,
                            color: priColor,
                            size: 20,
                          ),
                        ),
                        TextSpan(
                          text: " " + members[index].phone,
                          style: mainText(),
                        )
                      ],
                    ),
                  ),

                  Text.rich(
                    TextSpan(
                      style: mainText(),
                      children: [
                        WidgetSpan(
                          child: Icon(
                            Icons.alternate_email,
                            color: priColor,
                            size: 20,
                          ),
                        ),
                        TextSpan(
                          text: " " + members[index].email,
                          style: MainAccentText(),
                        )
                      ],
                    ),
                  ),
                  //

                  const SizedBox(
                    height: 5,
                  ),

                  Text.rich(
                    TextSpan(
                      style: mainText(),
                      children: [
                        WidgetSpan(
                          child: Icon(
                            Icons.calendar_today,
                            color: priColor,
                            size: 20,
                          ),
                        ),
                        TextSpan(
                          text:
                              " Since: ${DateFormatter().getVerboseDateTimeRepresentation(myDateFormartted(members[index].joinDate))}",
                          style: mainText(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        actionButton(
                            members[index].active.toString().compareTo('1') == 0
                                ? 'Deactivate'
                                : 'Activate',
                            members[index].active.toString().compareTo('1') == 0
                                ? Icons.cancel_rounded
                                : Icons.check_circle, () {
                          String memberStatus;
                          if (members[index].active.toString().compareTo('1') ==
                              0) {
                            memberStatus = "0";
                          } else {
                            memberStatus = "1";
                          }
                          DialogBuilder(context).showLoadingIndicator(
                              "Please wait as we effect the change ..",
                              "Membership");
                          activateorDeactivate(members[index].phone,
                              userGroupCode, memberStatus);
                        }),
                        const SizedBox(
                          height: 15,
                        ),
                        actionButton(
                            members[index].role.toString().compareTo('2') == 0
                                ? 'Not Mangr'
                                : 'Is Mangr',
                            members[index].role.toString().compareTo('1') == 0
                                ? Icons.cancel_rounded
                                : Icons.check_circle, () {
                          String memberRole;
                          if (members[index].role.toString().compareTo('0') ==
                              0) {
                            memberRole = "2";
                          } else {
                            memberRole = "0";
                          }
                          DialogBuilder(context).showLoadingIndicator(
                              "Please wait as we effect the change ..",
                              "Admin");
                          toFromAdmin(
                              members[index].phone, userGroupCode, memberRole);
                        }),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    scaffoldMessenger = ScaffoldMessenger.of(context);
    con = context;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: priColor,
        title: Text(
          "Membership Management (${members.length})",
          style: appBarText(),
          textAlign: TextAlign.center,
        ),
        //centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              _populateMembers;
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
      body: Column(
        children: [
          sortOptions(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 5, 24, 5),
            child: TextField(
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
                    hintText: 'Filter by Name, Email or Phone',
                    hintStyle: hiText()),
                onChanged: filterAction),
          ),
          Expanded(
            child: loadingMembers
                ? Center(
                    child: CircularProgressIndicator(
                      //  color: priAccentColor,
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(priColor),
                    ),
                  )
                : members.isEmpty
                    ? emptyListView("No members added yet..")
                    : ListView.builder(
                        itemCount: members.length,
                        itemBuilder: _buildItemsForListView,
                      ),
          ),
        ],
      ),
    );
  }

  void filterAction(string) {
    // Debouncer(milliseconds: 500).run(() {
    setState(() {
      members = allMembers
          .where((u) => (u.fname
                  .toString()
                  .toLowerCase()
                  .contains(string.toLowerCase()) ||
              u.lname.toString().toLowerCase().contains(string.toLowerCase()) ||
              u.phone.toString().toLowerCase().contains(string.toLowerCase()) ||
              u.email.toString().toLowerCase().contains(string.toLowerCase())))
          .toList();
    });
    //});
  }

  Widget sortOptions() {
    return DropdownButton<String>(
      focusColor: Colors.white,
      value: _sortValue,
      elevation: 5,
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.black,
      items: <String>[
        'First Name',
        'First Name Desc',
        'Email',
        'Email Desc',
        'Date Joined',
        'Date Joined Desc',
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
          _orderByMembers(_sortValue);
        });
      },
    );
  }

  void activateorDeactivate(
      String memberphone, String groupCode, memberStatus) {
    var client = http.Client();
    client.post(Uri.parse("${urlRoot}activateordeactivate.php"), body: {
      "phone": memberphone,
      "groupCode": groupCode,
      "active": memberStatus,
    }).then((response) {
      //setState(() {
      DialogBuilder(context).hideOpenDialog();
      //});
      client.close();
      if (mounted && response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['code'] == 1 || jsonResponse['code'] == 0) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Row(children: [
                  Icon(
                      jsonResponse['code'] == 1
                          ? Icons.check_circle
                          : Icons.error,
                      color: priColor),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Membership",
                    style: mainAccentText(),
                    textAlign: TextAlign.center,
                  ),
                ]),
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
                      _populateMembers();
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

  void toFromAdmin(String memberphone, String groupCode, memberStatus) {
    var client = http.Client();
    client.post(Uri.parse("${urlRoot}toorfromadmin.php"), body: {
      "phone": memberphone,
      "groupCode": groupCode,
      "role": memberStatus,
    }).then((response) {
      //setState(() {
      DialogBuilder(context).hideOpenDialog();
      //});
      client.close();
      if (mounted && response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['code'] == 1 || jsonResponse['code'] == 0) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Row(children: [
                  Icon(
                      jsonResponse['code'] == 1
                          ? Icons.check_circle
                          : Icons.error,
                      color: priColor),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Membership",
                    style: mainAccentText(),
                    textAlign: TextAlign.center,
                  ),
                ]),
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
                      _populateMembers();
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

  Future<void> editNamesPopUp(BuildContext context, String phone) async {
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
                "Edit Member Name",
                style: mainAccentText(),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildCodeTextField(Icons.account_box_outlined, 'First Name',
                      false, TextInputType.text, fnameController, 1, false),
                  buildTextField(Icons.account_box_outlined, 'Second Name',
                      false, TextInputType.text, snameController, 1)
                ],
              ),
              actions: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      actionButton('Cancel', Icons.cancel, () {
                        Navigator.pop(context);
                      }),
                      actionButton('Update', Icons.check_circle, () {
                        if (fnameController.text.isEmpty ||
                            fnameController.text.length < 3 ||
                            snameController.text.isEmpty ||
                            snameController.text.length < 3) {
                          showSnackBar(
                              "Provide valid First Name and Second Name");
                          return;
                        } else {
                          DialogBuilder(context).showLoadingIndicator(
                              "Please wait as we update member details ..",
                              "Updating...");
                          submitNameEdits(phone);
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

  void submitNameEdits(String memberPhone) {
    var client = http.Client();
    client.post(Uri.parse("${urlRoot}updatepassword.php"), body: {
      "phone": memberPhone,
      "firstName": fnameController.text.trim(),
      "secondName": snameController.text.trim(),
      "category": "adminNameChange",
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
                      "Member Name Edit",
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
                      setState(() {
                        fnameController.text = '';
                        snameController.text = '';
                        editName = false;
                      });
                      _populateMembers();
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
