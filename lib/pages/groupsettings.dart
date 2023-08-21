import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inuachama/models/group.dart';
import 'package:inuachama/util/configurations.dart';
import 'package:inuachama/util/templates.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:path/path.dart';

late ScaffoldMessengerState scaffoldMessenger;

enum InterestRate { compoundInterest, simpleInterest }

enum InterestFrequency { monthly, yearly }

class GroupSettings extends StatefulWidget {
  const GroupSettings({Key? key}) : super(key: key);

  @override
  _GroupSettingsState createState() => _GroupSettingsState();
}

class _GroupSettingsState extends State<GroupSettings> {
  TextEditingController rateController = TextEditingController();

  String rateLabel = "Update Interest Rate";
  bool editProfile = false;
  bool _toggleLoansModule = true;
  bool _toggleMembershipFeeModule = true;
  bool _toggleExpensesModule = true;
  bool _toggleFinesModule = true;
  bool _toggleContributionReminder = true;
  bool _toggleAdminRecords = true;
  bool _toggleDownloadReport = true;
  bool _toggleAccessAllReport = true;
  bool _toggleContributionEvents = true;
  bool _toggleSelfApprove = true;
  bool _toggleIncomeModule = true;
  bool _toggleAlertAll = true;
  bool _toggleShareCapitalModule = true;
  int dayofMonth = 5;
  final Prefs _prefs = Prefs();
  String imageUpload = "Update Logo";
  late File selectedImage;
  late Response response;
  late String progress;
  late String groupMembership = " ";
  late String groupCapacity = "";
  late String groupInterestRate = "";
  late String userGroupCode = "";
  String groupName = "";
  String groupImage = "";
  String image = "assets/images/logo.png";
  Dio dio = Dio();
  late BuildContext context;

  InterestRate _interestRate = InterestRate.compoundInterest;
  InterestFrequency _interestFrequency = InterestFrequency.monthly;

  @override
  void initState() {
    super.initState();
    getClickedGroupDetails();
  }

  void getClickedGroupDetails() {
    _prefs.getClickedGroup().then((group) => {
          setState(() => {
                userGroupCode = group.groupCode,
                _getProfileData(),
              })
        });
  }

  _getProfileData() {
    Webservice()
        .load(Group.all("getspecificgroup.php?groupCode=$userGroupCode"))
        .then((_groupData) => {
              setState(() {
                groupName = _groupData[0].groupName.toString();
                groupImage = _groupData[0].groupImage.toString();
                groupMembership = _groupData[0].groupMembers.toString();
                groupCapacity = _groupData[0].groupSize.toString();
                groupInterestRate = _groupData[0].groupInterestRate.toString();
                _toggleLoansModule =
                    _groupData[0].loansModule.toString().compareTo("1") == 0
                        ? true
                        : false;
                _toggleExpensesModule =
                    _groupData[0].expensesModule.toString().compareTo("1") == 0
                        ? true
                        : false;
                _toggleMembershipFeeModule = _groupData[0]
                            .membershipFeeModule
                            .toString()
                            .compareTo("1") ==
                        0
                    ? true
                    : false;

                _toggleFinesModule =
                    _groupData[0].finesModule.toString().compareTo("1") == 0
                        ? true
                        : false;
                _toggleContributionReminder = _groupData[0]
                            .contributionReminder
                            .toString()
                            .compareTo("1") ==
                        0
                    ? true
                    : false;
                _toggleDownloadReport =
                    _groupData[0].downloadReport.toString().compareTo("1") == 0
                        ? true
                        : false;
                _toggleIncomeModule =
                    _groupData[0].incomeModule.toString().compareTo("1") == 0
                        ? true
                        : false;
                _toggleAccessAllReport =
                    _groupData[0].accessReport.toString().compareTo("1") == 0
                        ? true
                        : false;
                _toggleAdminRecords =
                    _groupData[0].adminRecords.toString().compareTo("1") == 0
                        ? true
                        : false;
                _toggleContributionEvents = _groupData[0]
                            .contributionEvents
                            .toString()
                            .compareTo("1") ==
                        0
                    ? true
                    : false;

                _toggleSelfApprove =
                    _groupData[0].adminSelfApprove.toString().compareTo("1") ==
                            0
                        ? true
                        : false;
                _toggleShareCapitalModule =
                    _groupData[0].shareCapital.toString().compareTo("1") == 0
                        ? true
                        : false;
                _interestRate = _groupData[0]
                            .interestRateType
                            .toString()
                            .compareTo('compound') ==
                        0
                    ? InterestRate.compoundInterest
                    : InterestRate.simpleInterest;
                _interestFrequency = _groupData[0]
                            .interestRateFrequency
                            .toString()
                            .compareTo('monthly') ==
                        0
                    ? InterestFrequency.monthly
                    : InterestFrequency.yearly;
                dayofMonth = int.parse(
                    _groupData[0].contributionReminderDate.toString());
                rateController.text = groupInterestRate;
                // _prefs.addStringToSF("image", image);
              })
            });
  }

  @override
  Widget build(BuildContext con) {
    context = con;
    scaffoldMessenger = ScaffoldMessenger.of(context);
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: priColor,
          title: Text(
            'Group Settings',
            style: appBarText(),
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                editProfile ? Icons.edit_off : Icons.edit,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  editProfile = !editProfile;
                });
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              onPressed: () {
                // _populateTransactions();
              },
            ),
          ]),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!editProfile)
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "Click on the pen at the top right to edit values.",
                      style: mainText(),
                    ),
                  ),
                mySpace(20),
                CircleAvatar(
                  radius: 90,
                  backgroundColor: priAccentColor,

                  child: ClipOval(
                    child: CachedNetworkImage(
                        imageUrl: "${urlRoot}chamaimages/$groupImage",
                        fit: BoxFit.cover,
                        width: 200,
                        height: 200,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(
                              color: adminColor,
                              strokeWidth: 1,
                            ),

                        // You can use LinearProgressIndicator or CircularProgressIndicator instead

                        errorWidget: (context, url, error) {
                          //print("$error");
                          return Image.asset("assets/images/blank.png");
                        }),
                  ),

                  //backgroundColor: Colors.transparent,
                ),
                mySpace(10),
                myButton(imageUpload, 8, 20, () {
                  getImage();
                }, editProfile),
                mySpace(10),
                myDivider(),
                mySpace(10),
                Text(
                  groupName,
                  style: widgetTitleText(),
                ),
                mySpace(10),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text:
                        "Current members $groupMembership. Your Group maximum size is $groupCapacity",
                    style: widgetTitleText(),
                  ),
                ),
                mySpace(10),
                // Text(
                //   phone,
                //   style: widgetTitleText(),
                // ),
                mySpace(10),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text:
                        "Group maximum size and Name cannot be changed. Contact us to change",
                    style: mainText(),
                  ),
                ),
                mySpace(10),
                myDivider(),
                mySpace(10),

                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "Transaction Management:",
                    style: widgetTitleText(),
                  ),
                ),
                SwitchListTile(
                  activeColor: priColor,
                  inactiveThumbColor: hintColor,
                  //title: Text('Group Alerts', style: labelPriSmallColorText()),
                  subtitle: const Text(
                      'Admins Can Record transactions on behalf of members'),
                  secondary: Icon(Icons.list_alt_outlined,
                      color: _toggleAdminRecords ? priColor : priAccentColor),
                  onChanged: (value) {
                    setState(() {
                      _toggleAdminRecords = value;
                      _prefs.addBooleanToSF(
                          "adminRecords", _toggleAdminRecords);
                      updateSettings("adminRecords", _toggleAdminRecords);
                    });
                  },
                  value: _toggleAdminRecords,
                ),
                myDivider(1),
                SwitchListTile(
                  activeColor: priColor,
                  inactiveThumbColor: hintColor,
                  //title: Text('Group Alerts', style: labelPriSmallColorText()),
                  subtitle: const Text(
                      'Admins Cannot Approve their transactions or transactions they created. Use ONLY if you have more than 1 admins'),
                  secondary: Icon(Icons.verified_user,
                      color: _toggleSelfApprove ? priColor : priAccentColor),
                  onChanged: (value) {
                    setState(() {
                      _toggleSelfApprove = value;
                      _prefs.addBooleanToSF(
                          "adminSelfApprove", _toggleSelfApprove);
                      updateSettings("adminSelfApprove", _toggleSelfApprove);
                    });
                  },
                  value: _toggleSelfApprove,
                ),
                myDivider(),
                mySpace(10),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "Group Interest",
                    style: widgetTitleText(),
                  ),
                ),
                ListTile(
                  title: const Text('Compound Interest'),
                  leading: Radio(
                    value: InterestRate.compoundInterest,
                    groupValue: _interestRate,
                    onChanged: (InterestRate? value) {
                      setState(() {
                        _interestRate = value!;
                        updateGroupSettings(
                            "simpleORCompound",
                            _interestRate.toString().substring(
                                _interestRate.toString().indexOf('.') + 1));
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Simple Interest'),
                  leading: Radio(
                    value: InterestRate.simpleInterest,
                    groupValue: _interestRate,
                    onChanged: (InterestRate? value) {
                      setState(() {
                        _interestRate = value!;
                        updateGroupSettings(
                            "simpleORCompound",
                            _interestRate.toString().substring(
                                _interestRate.toString().indexOf('.') + 1));
                      });
                    },
                  ),
                ),
                myDivider(1),
                Column(
                  children: <Widget>[
                    ListTile(
                      title: const Text('Monthly'),
                      leading: Radio(
                        value: InterestFrequency.monthly,
                        groupValue: _interestFrequency,
                        onChanged: (InterestFrequency? value) {
                          setState(() {
                            _interestFrequency = value!;
                            updateGroupSettings(
                                "monthlyORYearly",
                                _interestFrequency.toString().substring(
                                    _interestFrequency.toString().indexOf('.') +
                                        1));
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Yearly'),
                      leading: Radio(
                        value: InterestFrequency.yearly,
                        groupValue: _interestFrequency,
                        onChanged: (InterestFrequency? value) {
                          setState(() {
                            _interestFrequency = value!;
                            updateGroupSettings(
                                "monthlyORYearly",
                                _interestFrequency.toString().substring(
                                    _interestFrequency.toString().indexOf('.') +
                                        1));
                          });
                        },
                      ),
                    ),
                  ],
                ),
                myDivider(1),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "Interest Rate value",
                    style: mainText(),
                  ),
                ),
                buildTextField(Icons.payment, "Interest Rate", false,
                    TextInputType.number, rateController),

                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text:
                        "The value entered is a percentage e.g 10 means 10%. Do not enter the percentage symbol.\nUpdated interest rate will not affect Interest values that have already been generated.",
                    style: mainText(),
                  ),
                ),

                mySpace(10),
                myButton(rateLabel, 10, 50, () {
                  if (!isDecimalNumber(rateController.text)) {
                    showSnackBar(
                        "${rateController.text} is NOT a valid Interest Rate value");
                    return;
                  } else {
                    String url = "${urlRoot}updateinterestrate.php";
                    setState(() {
                      rateLabel = "Updating Interest Rate..";
                    });
                    var client = http.Client();
                    client.post(Uri.parse(url), body: {
                      "groupCode": userGroupCode,
                      "newRate": rateController.text,
                    }).then((response) {
                      setState(() {
                        rateLabel = "Update Interest Rate";
                      });
                      client.close();
                      if (mounted && response.statusCode == 200) {
                        var jsonResponse = json.decode(response.body);
                        if (jsonResponse['code'] == 1 ||
                            jsonResponse['code'] == 0) {
                          _getProfileData();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  "Interest Rate Update",
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
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                    }).catchError((onError) {
                      client.close();
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              "Interest Rate Update",
                              style: mainAccentText(),
                              textAlign: TextAlign.center,
                            ),
                            content: Text(
                              "An error occurred $onError. Please retry",
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
                    });
                  }
                }, editProfile),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text:
                        "Current Setting: Interest is computed ${_interestFrequency.toString().substring(_interestFrequency.toString().indexOf('.') + 1)} at the rate of $groupInterestRate% by use of ${_interestRate.toString().substring(_interestRate.toString().indexOf('.') + 1)}",
                    style: mainText(),
                  ),
                ),
                mySpace(10),
                myDivider(),
                mySpace(10),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "Group Alerts:",
                    style: widgetTitleText(),
                  ),
                ),
                SwitchListTile(
                  activeColor: priColor,
                  inactiveThumbColor: hintColor,
                  //title: Text('Group Alerts', style: labelPriSmallColorText()),
                  subtitle: const Text(
                      'Send Alert to everyone in the group when a member transacts. When this option is off, alerts go to admins ONLY'),
                  secondary: Icon(Icons.notifications_on,
                      color: _toggleAlertAll ? priColor : priAccentColor),
                  onChanged: (value) {
                    setState(() {
                      _toggleAlertAll = value;
                      _prefs.addBooleanToSF("isAlertAll", _toggleAlertAll);
                      updateSettings("alertall", _toggleAlertAll);
                    });
                  },
                  value: _toggleAlertAll,
                ),
                myDivider(1),
                SwitchListTile(
                  activeColor: priColor,
                  inactiveThumbColor: hintColor,
                  //title: Text('Group Alerts', style: labelPriSmallColorText()),
                  subtitle: Text(
                      'Remind members if Contributions are not in by day $dayofMonth of every Month. The default Date is 5th'),
                  secondary: Icon(Icons.notifications_on,
                      color: _toggleContributionReminder
                          ? priColor
                          : priAccentColor),
                  onChanged: (value) {
                    setState(() {
                      _toggleContributionReminder = value;
                      _prefs.addBooleanToSF(
                          "contributionReminders", _toggleContributionReminder);
                      updateSettings(
                          "contributionReminders", _toggleContributionReminder);
                    });
                  },
                  value: _toggleContributionReminder,
                ),

                Visibility(
                  visible: _toggleContributionReminder,
                  child: Column(
                    children: [
                      NumberPicker(
                        axis: Axis.horizontal,
                        value: dayofMonth,
                        minValue: 1,
                        maxValue: 31,
                        onChanged: (value) =>
                            setState(() => dayofMonth = value),
                      ),
                      Text('Current day of the month: $dayofMonth'),
                      actionButton("Save Date", Icons.calendar_today_outlined,
                          () {
                        updateGroupSettings(
                            "contributionReminderDate", dayofMonth.toString());
                      }),
                    ],
                  ),
                ),

                myDivider(),
                mySpace(10),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "Group Modules:",
                    style: widgetTitleText(),
                  ),
                ),
                SwitchListTile(
                  activeColor: priColor,
                  inactiveThumbColor: hintColor,
                  //title: Text('Group Alerts', style: labelPriSmallColorText()),
                  subtitle: const Text(
                      'Activate or Deactivate Group Loan & Interest Modules'),
                  secondary: Icon(Icons.money,
                      color: _toggleLoansModule ? priColor : priAccentColor),
                  onChanged: (value) {
                    setState(() {
                      _toggleLoansModule = value;
                      _prefs.addBooleanToSF(
                          "isLoansModule", _toggleLoansModule);
                      updateSettings("loans", _toggleLoansModule);
                    });
                  },
                  value: _toggleLoansModule,
                ),
                myDivider(1),
                SwitchListTile(
                  activeColor: priColor,
                  inactiveThumbColor: hintColor,
                  //title: Text('Group Alerts', style: labelPriSmallColorText()),
                  subtitle: const Text(
                      'Activate or Deactivate Group Membership Fee Module'),
                  secondary: Icon(Icons.groups,
                      color: _toggleMembershipFeeModule
                          ? priColor
                          : priAccentColor),
                  onChanged: (value) {
                    setState(() {
                      _toggleMembershipFeeModule = value;
                      _prefs.addBooleanToSF(
                          "isMembershipFee", _toggleMembershipFeeModule);
                      updateSettings("membership", _toggleMembershipFeeModule);
                    });
                  },
                  value: _toggleMembershipFeeModule,
                ),

                myDivider(1),
                SwitchListTile(
                  activeColor: priColor,
                  inactiveThumbColor: hintColor,
                  //title: Text('Group Alerts', style: labelPriSmallColorText()),
                  subtitle:
                      const Text('Activate or Deactivate Share Capital Module'),
                  secondary: Icon(Icons.currency_exchange_outlined,
                      color: _toggleShareCapitalModule
                          ? priColor
                          : priAccentColor),
                  onChanged: (value) {
                    setState(() {
                      _toggleShareCapitalModule = value;
                      _prefs.addBooleanToSF(
                          "isShareCapital", _toggleShareCapitalModule);
                      updateSettings("sharecapital", _toggleShareCapitalModule);
                    });
                  },
                  value: _toggleShareCapitalModule,
                ),

                myDivider(1),
                SwitchListTile(
                  activeColor: priColor,
                  inactiveThumbColor: hintColor,
                  //title: Text('Group Alerts', style: labelPriSmallColorText()),
                  subtitle: const Text(
                      'Activate or Deactivate Group Expenses Module'),
                  secondary: Icon(Icons.arrow_drop_down_circle_rounded,
                      color: _toggleExpensesModule ? priColor : priAccentColor),
                  onChanged: (value) {
                    setState(() {
                      _toggleExpensesModule = value;
                      _prefs.addBooleanToSF(
                          "isExpenseModule", _toggleExpensesModule);
                      updateSettings("expenses", _toggleExpensesModule);
                    });
                  },
                  value: _toggleExpensesModule,
                ),
                myDivider(1),
                SwitchListTile(
                  activeColor: priColor,
                  inactiveThumbColor: hintColor,
                  //title: Text('Group Alerts', style: labelPriSmallColorText()),
                  subtitle: const Text(
                      'Activate or Deactivate Other Group Income Module'),
                  secondary: Icon(Icons.incomplete_circle,
                      color: _toggleIncomeModule ? priColor : priAccentColor),
                  onChanged: (value) {
                    setState(() {
                      _toggleIncomeModule = value;
                      _prefs.addBooleanToSF(
                          "isIncomeModule", _toggleIncomeModule);
                      updateSettings("otherincomes", _toggleIncomeModule);
                    });
                  },
                  value: _toggleIncomeModule,
                ),
                myDivider(1),
                SwitchListTile(
                  activeColor: priColor,
                  inactiveThumbColor: hintColor,
                  //title: Text('Group Alerts', style: labelPriSmallColorText()),
                  subtitle:
                      const Text('Activate or Deactivate Group Fines Module'),
                  secondary: Icon(Icons.arrow_forward_ios_rounded,
                      color: _toggleFinesModule ? priColor : priAccentColor),
                  onChanged: (value) {
                    setState(() {
                      _toggleFinesModule = value;
                      _prefs.addBooleanToSF(
                          "isFinesModule", _toggleFinesModule);
                      updateSettings("fines", _toggleFinesModule);
                    });
                  },
                  value: _toggleFinesModule,
                ),
                myDivider(1),
                SwitchListTile(
                  activeColor: priColor,
                  inactiveThumbColor: hintColor,
                  //title: Text('Group Alerts', style: labelPriSmallColorText()),
                  subtitle: const Text(
                      'Activate or Deactivate Contributions association with Events'),
                  secondary: Icon(Icons.calendar_month,
                      color: _toggleContributionEvents
                          ? priColor
                          : priAccentColor),
                  onChanged: (value) {
                    setState(() {
                      _toggleContributionEvents = value;
                      _prefs.addBooleanToSF(
                          "contributionEvents", _toggleContributionEvents);
                      updateSettings(
                          "contributionEvents", _toggleContributionEvents);
                    });
                  },
                  value: _toggleContributionEvents,
                ),
                mySpace(10),
                myDivider(),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "Group Reports:",
                    style: widgetTitleText(),
                  ),
                ),
                SwitchListTile(
                  activeColor: priColor,
                  inactiveThumbColor: hintColor,
                  //title: Text('Group Alerts', style: labelPriSmallColorText()),
                  subtitle: const Text(
                      'Group members can only access their reports -not group reports'),
                  secondary: Icon(Icons.picture_as_pdf,
                      color:
                          _toggleAccessAllReport ? priColor : priAccentColor),
                  onChanged: (value) {
                    setState(() {
                      _toggleAccessAllReport = value;
                      _prefs.addBooleanToSF(
                          "accessreports", _toggleAccessAllReport);
                      updateSettings("accessreports", _toggleAccessAllReport);
                    });
                  },
                  value: _toggleAccessAllReport,
                ),
                myDivider(1),
                SwitchListTile(
                  activeColor: priColor,
                  inactiveThumbColor: hintColor,
                  //title: Text('Group Alerts', style: labelPriSmallColorText()),
                  subtitle: const Text(
                      'Group members can download reports they have access to'),
                  secondary: Icon(Icons.download,
                      color: _toggleDownloadReport ? priColor : priAccentColor),
                  onChanged: (value) {
                    setState(() {
                      _toggleDownloadReport = value;
                      _prefs.addBooleanToSF(
                          "isDownloadReport", _toggleDownloadReport);
                      updateSettings("downloadReport", _toggleDownloadReport);
                    });
                  },
                  value: _toggleDownloadReport,
                ),

                mySpace(10),
                myDivider(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future getImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      selectedImage = File(image!.path);
    });
    uploadImage();
  }

  uploadImage() async {
    String uploadurl = "${urlRoot}updategrouplogo.php";

    FormData formdata = FormData.fromMap({
      "image": await MultipartFile.fromFile(selectedImage.path,
          filename: basename(selectedImage.path)
          //show only filename from path
          ),
      "groupCode": userGroupCode
    });

    response = await dio.post(
      uploadurl,
      data: formdata,
      onSendProgress: (int sent, int total) {
        double percentage = ((sent / total) * 100);
        setState(() {
          ///progress
          imageUpload = "${percentage.round()}% uploaded..";
          if (percentage.round() == 100) {
            imageUpload = "Update Logo";
            _getProfileData();
          }
        });
      },
    );

    if (response.statusCode == 200) {
      imageUpload = "Update Logo";
      _getProfileData();
    } else {
      setState(() {
        imageUpload = "Update Logo";
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Logo Update",
              style: mainAccentText(),
              textAlign: TextAlign.center,
            ),
            content: Text(
              "Error updating email. Try later.",
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
    }
  }

  void updateSettings(String setting, bool value) {
    String url = "${urlRoot}updateGroupSettings.php";
    var client = http.Client();
    client.post(Uri.parse(url), body: {
      "groupCode": userGroupCode,
      "settings": setting,
      "value": value ? "1" : "0",
    }).then((response) {
      client.close();
      if (mounted && response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['code'] == 1 || jsonResponse['code'] == 0) {
          _getProfileData();
          showSnackBar((jsonResponse['message']));
        }
      }
    }).catchError((onError) {
      client.close();
      showSnackBar(
        "Error occurred while updating group preferences$onError",
      );
    });
  }

  void updateGroupSettings(String setting, String value) {
    String url = "${urlRoot}updateGroupSettings.php";
    var client = http.Client();
    client.post(Uri.parse(url), body: {
      "groupCode": userGroupCode,
      "settings": setting,
      "value": value,
    }).then((response) {
      client.close();
      if (mounted && response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['code'] == 1 || jsonResponse['code'] == 0) {
          _getProfileData();
          showSnackBar(jsonResponse['message']);
        }
      }
    }).catchError((onError) {
      client.close();
      showSnackBar("Error occurred while updating group preferences $onError");
    });
  }
}
