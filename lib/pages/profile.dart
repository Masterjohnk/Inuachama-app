import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inuachama/models/profiledata.dart';
import 'package:inuachama/util/configurations.dart';
import 'package:inuachama/util/templates.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  TextEditingController emailController = TextEditingController();
  TextEditingController piController = TextEditingController();
  TextEditingController pi2Controller = TextEditingController();
  String emailLabel = "Update Email";
  String pinLabel = "Update PIN";
  bool editProfile = false;
  final Prefs _prefs = Prefs();
  String imageUpload = "Update Image";
  late File selectedImage;
  late Response response;
  late String userPhone;
  late String progress;
  late String fname = " ";
  late String lname = " ";
  late String email;
  late String phone = "";
  late String title = "";
  String image = "assets/images/blank.png";
  Dio dio = Dio();
  late BuildContext context;

  @override
  void initState() {
    super.initState();
    getPhone();
  }

  void getPhone() {
    _prefs.getStringValuesSF('phone').then((phone) => {
          setState(() => {
                userPhone = phone!,
                _getProfileData(),
              })
        });
  }

  _getProfileData() {
    Webservice()
        .load(ProfileData.getProfile(userPhone))
        .then((_profileData) => {
              setState(() {
                fname = _profileData[0].fname.toString();
                lname = _profileData[0].lname.toString();
                email = _profileData[0].email.toString();
                image = _profileData[0].image.toString();
                phone = _profileData[0].phone.toString();
                title = _profileData[0].title.toString();
                emailController.text = email.toString();
                _prefs.addStringToSF("image", image);
              })
            });
  }

  @override
  Widget build(BuildContext con) {
    context = con;
    var scaffoldMessenger = ScaffoldMessenger.of(context);
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: priColor,
          title: Text(
            'Profile',
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
            )
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
                      imageUrl: "${urlRoot}profilepics/$image",
                      fit: BoxFit.fitHeight,
                      width: 200,
                      height: 200,
                      placeholder: (context, url) => CircularProgressIndicator(
                        color: priAccentColor,
                        strokeWidth: 1,
                      ),
                      errorWidget: (context, url, error) =>
                          Image.asset("assets/images/blank.png"),
                    ),
                  ),

                  //backgroundColor: Colors.transparent,
                ),
                mySpace(20),
                myButton(imageUpload, 8, 20, () {
                  getImage();
                }, editProfile),
                mySpace(20),
                myDivider(),
                mySpace(20),
                Text(
                  "$fname $lname",
                  style: widgetTitleText(),
                ),
                mySpace(20),
                Text(
                  title,
                  style: widgetTitleText(),
                ),
                mySpace(20),
                Text(
                  phone,
                  style: widgetTitleText(),
                ),
                mySpace(10),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "Phone number and Name cannot be changed.",
                    style: mainText(),
                  ),
                ),
                mySpace(20),
                myDivider(),
                mySpace(20),
                buildTextField(Icons.email, "Email", false,
                    TextInputType.emailAddress, emailController),
                mySpace(),
                myButton(emailLabel, 10, 50, () {
                  if (!isEmail(emailController.text)) {
                    showSnackBar("Provide a valid email");
                    return;
                  } else {
                    String url = "${urlRoot}updateEmail.php";
                    setState(() {
                      emailLabel = "Updating Email..";
                    });
                    var client = http.Client();
                    client.post(Uri.parse(url), body: {
                      "phone": userPhone,
                      "email": emailController.text,
                    }).then((response) {
                      setState(() {
                        emailLabel = "Update Email";
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
                                  "Email Update",
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
                                      if (jsonResponse['code'] == 1) {
                                        emailController.clear();
                                      }
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
                              "Email Update",
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
                mySpace(20),
                myDivider(),
                mySpace(20),
                buildTextField(Icons.lock, "PIN", true, TextInputType.number,
                    piController),
                mySpace(),
                buildTextField(Icons.lock, "Confirm PIN", true,
                    TextInputType.number, pi2Controller),
                mySpace(20),
                myButton(pinLabel, 10, 50, () {
                  if (piController.text.isEmpty ||
                      pi2Controller.text.isEmpty ||
                      piController.text.compareTo(piController.text) != 0) {
                    showSnackBar("Provide two non-empty & matching PINs");
                    return;
                  } else {
                    setState(() {
                      pinLabel = "Updating PIN..";
                    });
                    var client = http.Client();
                    client
                        .post(Uri.parse("${urlRoot}updatepassword.php"), body: {
                      "phone": userPhone,
                      "password": piController.text,
                      "category": "password",
                    }).then((response) {
                      setState(() {
                        pinLabel = "Update PIN";
                      });
                      client.close();
                      if (mounted && response.statusCode == 200) {
                        var jsonResponse = json.decode(response.body);
                        if (jsonResponse['code'] == 1 ||
                            jsonResponse['code'] == 0) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  "PIN Update",
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
                                      if (jsonResponse['code'] == 1) {
                                        piController.clear();
                                        pi2Controller.clear();
                                        _getProfileData();
                                      }
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
                              "PIN Update",
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
                mySpace(20),
                myDivider(),
                mySpace(20),
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
    String uploadurl = "${urlRoot}updateimage.php";

    FormData formdata = FormData.fromMap({
      "image": await MultipartFile.fromFile(selectedImage.path,
          filename: basename(selectedImage.path)
          //show only filename from path
          ),
      "phone": userPhone
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
            imageUpload = "Update Image";
            _getProfileData();
          }
        });
      },
    );

    if (response.statusCode == 200) {
      imageUpload = "Update Image";
      _getProfileData();
    } else {
      setState(() {
        imageUpload = "Update Image";
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Image Update",
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
}
