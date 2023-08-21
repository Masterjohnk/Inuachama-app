import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:inuachama/models/loggedinuser.dart';
import 'package:inuachama/util/configurations.dart';
import 'package:inuachama/util/templates.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../util/responsive_manager.dart';

enum ResetOption { otp, reset }

ResetOption resetOption = ResetOption.otp;

class LoginSignUpScreen extends StatefulWidget {
  const LoginSignUpScreen({Key? key}) : super(key: key);

  @override
  _LoginSignUpScreenState createState() => _LoginSignUpScreenState();
}

class _LoginSignUpScreenState extends State<LoginSignUpScreen> {
  bool isSignUpScreen = false;
  bool isRememberMe = false;
  final Prefs _prefs = Prefs();
  TextEditingController fNameController = TextEditingController();
  TextEditingController sNameController = TextEditingController();
  TextEditingController piController = TextEditingController();
  TextEditingController pi2Controller = TextEditingController();
  TextEditingController piNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController resetemailController = TextEditingController();
  TextEditingController phController = TextEditingController();

  TextEditingController resetpin1Controller = TextEditingController();
  TextEditingController resetpin2Controller = TextEditingController();
  TextEditingController otpController = TextEditingController();
  TextEditingController memberIDController = TextEditingController();
  late ScaffoldMessengerState scaffoldMessenger;
  var errorMsg;
  String deviceID = "";

  @override
  void initState() {
    super.initState();
    getIsRemember();
  }

  void getIsRemember() {
    _prefs.getBooleanValuesSF('isRemember').then((remember) => {
          setState(() => {
                isRememberMe = remember!,
                if (isRememberMe)
                  {
                    _prefs.getStringValuesSF('phone').then((phone) => {
                          setState(() => {
                                phController.text = phone!,
                              })
                        })
                  }
              })
        });
  }

  @override
  Widget build(BuildContext context) {
    scaffoldMessenger = ScaffoldMessenger.of(context);
    return Scaffold(
        backgroundColor: priColorShade,
        body: Stack(alignment: Alignment.center, children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height / 2,
              decoration: BoxDecoration(
                color: priColor,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(70),
                  bottomLeft: Radius.circular(70),
                ),
                border: Border.all(
                  width: 3,
                  color: priColor,
                  style: BorderStyle.solid,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.only(top: 40),
                //color: primaryAccentColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      " InuaChama",
                      style: appNameText(),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Transparent & Efficient",
                      style: labelWhiteSmallerText(),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: isSignUpScreen ? 130 : 250,
            child: Container(
              padding: const EdgeInsets.all(15),
              //height: 520,
              width: MediaQuery.of(context).size.width < widthMobile
                  ? MediaQuery.of(context).size.width - 40
                  : 400,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: secbgColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 0,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isSignUpScreen = false;
                          });
                        },
                        child: Column(
                          children: [
                            Text(
                              'LOGIN',
                              style: mainText(),
                            ),
                            if (!isSignUpScreen)
                              Container(
                                  margin: const EdgeInsets.only(top: 3),
                                  height: 2,
                                  width: 55,
                                  color:
                                      isSignUpScreen ? inactiveColor : priColor)
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isSignUpScreen = true;
                          });
                        },
                        child: Column(
                          children: [
                            Text(
                              'SIGNUP',
                              style: mainText(),
                            ),
                            if (isSignUpScreen)
                              SingleChildScrollView(
                                child: Container(
                                    margin: const EdgeInsets.only(top: 3),
                                    height: 2,
                                    width: 55,
                                    color: isSignUpScreen
                                        ? priColor
                                        : inactiveColor),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  if (isSignUpScreen)
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          buildTextField(Icons.account_box, "First Name", false,
                              TextInputType.text, fNameController),
                          buildTextField(Icons.account_box, "Second Name",
                              false, TextInputType.text, sNameController),
                          buildTextField(Icons.email, "Email", false,
                              TextInputType.emailAddress, emailController),
                          buildTextField(Icons.phone, "Phone number", false,
                              TextInputType.phone, phController),
                          buildTextField(Icons.lock, "PIN", true,
                              TextInputType.number, piController),
                          buildTextField(Icons.lock, "Confirm PIN", true,
                              TextInputType.number, pi2Controller),
                          Text(
                            'If your chama/welfare group has Membership numbers, Please enter yours below. You can leave it blank',
                            style: verysmallText(),
                            textAlign: TextAlign.center,
                          ),
                          buildTextField(Icons.account_box, "Member ID", false,
                              TextInputType.text, memberIDController),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text:
                                  "By proceeding you agree to our terms & conditions",
                              style: hiText(),
                            ),
                          ),
                          const SizedBox(height: 5),
                          myButton("Signup", 10, 50, () {
                            signUP();
                          }),
                        ],
                      ),
                    ),
                  if (!isSignUpScreen)
                    Align(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildTextField(Icons.phone, "Phone number", false,
                              TextInputType.phone, phController),
                          buildTextField(Icons.lock, "PIN", true,
                              TextInputType.number, piController),
                          const SizedBox(
                            height: 3,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              //SizedBox
                              Checkbox(
                                value: isRememberMe,
                                activeColor: adminColor,
                                onChanged: (bool? isRemember) {
                                  setState(() {
                                    isRememberMe = isRemember!;
                                  });
                                },
                              ),
                              Text(
                                'Remember Phone number',
                                style: mainText(),
                              ), //Text
                              const SizedBox(width: 5), //SizedBox
                              //Checkbox
                            ], //<Widget>[]
                          ),
                          myButton("Login", 10, 50, () {
                            login();
                          }),
                          mySpace(20),
                          InkWell(
                            child: Text(
                              'Reset PIN',
                              style: TextStyle(
                                  color: adminColor,
                                  fontSize: 15,
                                  decoration: TextDecoration.underline,
                                  decorationStyle: TextDecorationStyle.solid),
                            ),
                            onTap: () {
                              resetPasswordPop(context);
                            },
                          )
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 720,
            bottom: 50,
            child: Column(
              children: [
                Text(
                  'Safeguarding members\' interest..',
                  style: hiText(),
                ),
                const SizedBox(
                  height: 10,
                ),
                // RichText(
                //   text: TextSpan(
                //     style: myTextStyle(priColor, 18, FontWeight.w300),
                //     children: <TextSpan>[
                //       const TextSpan(text: 'Powered by '),
                //       TextSpan(
                //           text: 'Agile Code',
                //           style: myTextStyle(adminColor, 18, FontWeight.w300,
                //               underline: true),
                //           recognizer: TapGestureRecognizer()
                //             ..onTap = () async {
                //               try {
                //                 await launchUrl(
                //                     Uri.parse("https://agilecode.co.ke"));
                //               } catch (e) {
                //                 //print(e.toString());
                //               }
                //             }),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ]));
  }

  signIn(String mobile, pass) async {
    DialogBuilder(context).showLoadingIndicator(
        "Please wait as we authenticate you", "Authentication");
    Map data = {'phone': mobile, 'password': pass, 'key': deviceID};
    var jsonResponse;
    var response = await http.post(Uri.parse(API("login")), body: data);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        setState(() {
          DialogBuilder(context).hideOpenDialog();
        });
        int isRegistered = jsonResponse['code'];
        if (isRegistered == 1) {
          var userDetails = jsonResponse['userdetails'];
          String userImage = userDetails[0]['image'].toString();
          String fName = userDetails[0]['fname'].toString();
          String lName = userDetails[0]['lname'].toString();
          String userPhone = userDetails[0]['phone'].toString();
          LoggedInUser loggedInUser =
              LoggedInUser(fName, lName, userPhone, userImage);
          _prefs.addBooleanToSF("isRemember", isRememberMe);
          phController.text = "";
          piController.text = "";
          _prefs.saveLoggedUser(loggedInUser).then((p) => {
                Get.offAllNamed('/groups'),
              });
        } else if (isRegistered == 5) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
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
                    "Login",
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
                      phController.text = "";
                      piController.text = "";
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else if (isRegistered == 10) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  "Login",
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
                      phController.text = "";
                      piController.text = "";
                    },
                  ),
                ],
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  "Login",
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
    } else {
      setState(() {
        DialogBuilder(context).hideOpenDialog();
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Login",
              style: mainAccentText(),
              textAlign: TextAlign.center,
            ),
            content: Text(
              "${errorMsg}  Error code: ${response.statusCode}",
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

  signUp(String fname, String lname, String email, String phone, pass,
      String memberID) async {
    DialogBuilder(context)
        .showLoadingIndicator("Please wait as we register you", "Registration");
    Map data = {
      'fname': fname,
      'lname': lname,
      'phone': phone,
      'email': email,
      'password': pass,
      'key': deviceID,
      'memberID': memberID
    };

    var jsonResponse;
    var response = await http.post(Uri.parse(API("signup")), body: data);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);

      if (jsonResponse != null) {
        setState(() {
          DialogBuilder(context).hideOpenDialog();
        });

        int isRegistered = jsonResponse['code'];
        if (isRegistered == 1) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  "Registration",
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
                      clearFields();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else if (isRegistered == 3) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  "Registration",
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
                      clearFields();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          //scaffoldMessenger.showSnackBar(mySnackBar(jsonResponse['message']));
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  "Registration",
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
                      clearFields();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    } else {
      setState(() {
        DialogBuilder(context).hideOpenDialog();
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Registration",
              style: mainAccentText(),
              textAlign: TextAlign.center,
            ),
            content: Text(
              "${errorMsg} Error code: ${response.statusCode}",
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

  login() {
    {
      if (phController.text.isEmpty) {
        showSnackBar("Provide Phone number");
        return;
      } else if (piController.text.isEmpty) {
        showSnackBar("Provide PIN");
        return;
      } else {
        setState(() {});
        signIn(phController.text, piController.text);
      }
    }
  }

  clearFields() {
    fNameController.text = '';
    sNameController.text = '';
    emailController.text = '';
    phController.text = '';
    piController.text = '';
    pi2Controller.text = '';
    resetpin1Controller.text = '';
    resetpin2Controller.text = '';
    resetemailController.text = '';
    otpController.text = '';
    memberIDController.text = '';
  }

  signUP() {
    if (fNameController.text.isEmpty) {
      showSnackBar("Provide First Name");
      return;
    } else if (sNameController.text.isEmpty) {
      showSnackBar("Provide Second Name");
      return;
    } else if (!isEmail(emailController.text.trim())) {
      showSnackBar("Provide a valid email");
      return;
    } else if (!validateMobile(phController.text)) {
      showSnackBar(
        "Provide a valid phone",
      );
      return;
    } else if (piController.text.isEmpty ||
        pi2Controller.text.isEmpty ||
        piController.text.compareTo(piController.text) != 0) {
      showSnackBar(
        "Provide two non-empty & matching PINs",
      );
      return;
    } else {
      setState(() {});
      signUp(
          fNameController.text,
          sNameController.text,
          emailController.text.trim(),
          phController.text,
          piController.text,
          memberIDController.text);
    }
  }

  Future<void> resetPasswordPop(BuildContext context) async {
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
                "Password Reset",
                style: mainAccentText(),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "First request OTP by entering your account Email address OR Phone number. The OTP will be send to your email. Once you have it, come back here and select \"Already have OTP\" enter the OTP and new PIN to reset ",
                    style: verysmallText(),
                    textAlign: TextAlign.center,
                  ),
                  ListTile(
                    horizontalTitleGap: 1,
                    title: const Text('OTP Request'),
                    leading: Radio(
                      value: ResetOption.otp,
                      groupValue: resetOption,
                      onChanged: (ResetOption? value) {
                        setState(() {
                          resetOption = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    minVerticalPadding: 1,
                    horizontalTitleGap: 1,
                    title: const Text('Already have OTP'),
                    leading: Radio(
                      value: ResetOption.reset,
                      groupValue: resetOption,
                      onChanged: (ResetOption? value) {
                        setState(() {
                          resetOption = value!;
                        });
                      },
                    ),
                  ),
                  if (resetOption.index == 0)
                    Column(
                      children: [
                        buildTextField(Icons.lock, 'Account Email or Phone',
                            false, TextInputType.text, resetemailController, 1),
                      ],
                    ),
                  if (resetOption.index == 1)
                    Column(
                      children: [
                        buildTextField(Icons.lock, 'OTP', false,
                            TextInputType.text, otpController, 1),
                        buildTextField(Icons.lock, 'New PIN', false,
                            TextInputType.text, resetpin1Controller, 1),
                        buildTextField(Icons.lock, 'Confirm PIN', false,
                            TextInputType.text, resetpin2Controller, 1),
                      ],
                    )
                ],
              ),
              actions: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      actionButton('Cancel', Icons.cancel, () {
                        Navigator.pop(context);
                      }),
                      actionButton(resetOption.index == 0 ? 'Request' : 'Reset',
                          Icons.check_circle, () {
                        if (resetOption.index == 0) {
                          if (resetemailController.text.isEmpty) {
                            showSnackBar(
                                "Provide a valid Email address or Phone number");
                            return;
                          }
                        } else {
                          if (resetpin1Controller.text.isEmpty ||
                              otpController.text.isEmpty ||
                              resetpin2Controller.text.isEmpty ||
                              resetpin1Controller.text.trim().compareTo(
                                      resetpin1Controller.text.trim()) !=
                                  0) {
                            showSnackBar(
                                "OTP, New PIN and Confirm PIN cannot be empty. In addition, New PIN and Confirm PIN must match.");
                            return;
                          }
                        } //else {
                        DialogBuilder(context).showLoadingIndicator(
                            resetOption.index == 0
                                ? "Please wait as we send OTP to email .."
                                : "Please wait as we reset your PIN...",
                            resetOption.index == 0
                                ? "Requesting.."
                                : "Resetting...");
                        resetPassword(context);
                        //}
                      })
                    ])
              ],
            ),
          );
        });
      },
    );
  }

  void resetPassword(BuildContext context) {
    var client = http.Client();
    client.post(Uri.parse("${urlRoot}passwordrecover.php"), body: {
      "resetOption": resetOption.index.toString(),
      "emailORPassword": resetemailController.text.trim(),
      "OTP": resetOption.index == 0 ? '' : otpController.text.trim(),
      "newPIN": resetOption.index == 0 ? '' : resetpin1Controller.text.trim(),
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
                      "Password Reset",
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
                      clearFields();
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
