import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inuachama/models/clickedgroup.dart';
import 'package:inuachama/models/loggedinuser.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String appName = "";
const String fontName = 'NunitoSans-Regular';
Prefs prefs = Prefs();
String currentFont = Prefs().getStringValuesSF('currentFont') as String;
bool _isConnected = false;
var priColor = const Color(0xFFec9730);
var priColorShade = Colors.grey.shade100;
var adminColor = const Color(0xFFec9730);
var adminColorShade = const Color(0xFFFFC34D);
var greenColor = const Color(0xff13d38e);
var greenColorShade = const Color(0xffB6EA7D);
var redColor = Colors.red;
var redColorShades = const Color(0xffffb3b3);
var goldColorShades = const Color(0xFFFDDF5B);
var blueColorShades = const Color(0xFFb3b3ff);
var pinkColorShades = const Color(0xFFFFC0CB);
var greenyColorShades = const Color(0xFF50C878);
var priAccentColor = priColor.withOpacity(0.4);
var transparentColor = const Color(0x00FFFFFF);
const secbgColor = Colors.white;
var bgColor = Colors.grey[200];
var appBlack = Colors.black87;
var inactiveColor = Colors.grey[500];
var greyColor = Colors.grey[800];
var hintColor = Colors.grey[800];
const secColor = Colors.white;
var transColor = Colors.transparent;
var defaultPadding = 10.0;
const urlRoot = "https://www.churchapp.co.ke/inuachama/";
ThemeData myTheme() {
  return ThemeData(
    primaryColor: priColor,
    //scaffoldBackgroundColor: priAccentColor,
    primarySwatch: createMaterialColor(priAccentColor),
    brightness: Brightness.light,
    fontFamily: fontName,
  );
}
Widget emptyListView(message) {
  return Center(
    child: Text(
      message,
      style: mainText(),
    ),
  );
}

Widget buildInterestItem(BuildContext context, int index) {
  return Card(
    color: Colors.white,
    margin: const EdgeInsets.fromLTRB(5, 2, 5, 2),
    shadowColor: priColor,
    borderOnForeground: true,
    elevation: 1.0,
    child: Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Amount",
                  style: labelPriSmallColorText(),
                ),
                Text(
                  'Total: ',
                  style: mainText(),
                ),
                Text(
                  "2000",
                  style: mainText(),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Future<bool> showExitPopup(BuildContext context) async {
  return await showDialog(
        //show confirm dialogue
        //the return value will be from "Yes" or "No" options
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Exit InuaChama',
            style: mainAccentText(),
          ),
          content: Text(
            'Do you want to exit InuaChama?',
            style: mainText(),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                actionButton(
                  "No",
                  Icons.cancel_rounded,
                  () => Navigator.of(context).pop(false),
                ),
                actionButton(
                  "Yes",
                  Icons.check_circle,
                  () => {
                    //Navigator.pop(
                    //context, true), // It worked for me instead of above line
                    SystemNavigator.pop(),
                  },
                ),
              ],
            )
          ],
        ),
      ) ??
      false; //if showDialouge had returned null, then return false
}

void noInternet(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          "Internet Connection",
          style: mainAccentText(),
          textAlign: TextAlign.center,
        ),
        content: Text(
          "You are not connected to the Internet",
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

formatDate(dateTime) {
  return DateFormat(
    'EE, dd-MMM-yy',
  ).format(dateTime);
}

BottomNavigationBarItem menuIcon(IconData icon, String label) {
  return BottomNavigationBarItem(
    icon: Icon(
      icon,
      size: 24,
    ),
    label: label,
    backgroundColor: Colors.white,
  );
}

Future<bool?> getPreferences(key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? val = await prefs.getBool(key);
  return val;
}

TextStyle menuText() {
  return TextStyle(
      fontFamily: fontName,
      color: hintColor,
      fontSize: 14,
      fontWeight: FontWeight.w200);
}

TextStyle dashText() {
  return TextStyle(
      fontFamily: fontName,
      color: hintColor,
      fontSize: 15,
      fontWeight: FontWeight.w300);
}

TextStyle appBarText() {
  return const TextStyle(
      fontFamily: fontName,
      color: secColor,
      fontSize: 20,
      fontWeight: FontWeight.w300);
}

TextStyle widgetTitleText() {
  return TextStyle(
      fontFamily: fontName,
      color: priColor,
      fontSize: 18,
      fontWeight: FontWeight.w300);
}

TextStyle labelWhiteText() {
  return const TextStyle(
      fontFamily: fontName,
      color: secColor,
      fontSize: 18,
      fontWeight: FontWeight.w300);
}

TextStyle appNameText() {
  return const TextStyle(
      fontFamily: fontName,
      color: secColor,
      fontSize: 25,
      fontWeight: FontWeight.w500);
}

TextStyle labelPriColorText() {
  return TextStyle(
      fontFamily: fontName,
      color: priColor,
      fontSize: 14,
      fontWeight: FontWeight.w400);
}

TextStyle labelBlackText() {
  return TextStyle(
      fontFamily: fontName,
      color: appBlack,
      fontSize: 14,
      fontWeight: FontWeight.bold);
}

TextStyle labelPriSmallColorText() {
  return TextStyle(
      fontFamily: fontName,
      color: priColor,
      fontSize: 14,
      fontWeight: FontWeight.w600);
}

TextStyle labelWhiteSmallerText() {
  return const TextStyle(
      fontFamily: fontName,
      color: secColor,
      fontSize: 16,
      fontWeight: FontWeight.w300);
}

TextStyle mainText() {
  return TextStyle(
      fontFamily: fontName,
      color: greyColor,
      fontSize: 15,
      fontWeight: FontWeight.w100);
}

TextStyle MainAccentText() {
  return TextStyle(
      fontFamily: fontName,
      color: priColor,
      fontSize: 14,
      fontWeight: FontWeight.w400);
}

TextStyle MainAccentTextGray() {
  return TextStyle(
      fontFamily: fontName,
      color: greyColor,
      fontSize: 14,
      fontWeight: FontWeight.w300);
}

TextStyle mainAccentText() {
  return TextStyle(
      fontFamily: fontName,
      color: priColor,
      fontSize: 18,
      fontWeight: FontWeight.w400);
}

TextStyle mainBoldText() {
  return TextStyle(
      fontFamily: fontName,
      color: greyColor,
      fontSize: 18,
      fontWeight: FontWeight.w400);
}

TextStyle myTextStyle(Color? color, double fontSize, FontWeight fontWeight,
    {bool underline = false}) {
  return TextStyle(
      fontFamily: fontName,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      decoration: underline ? TextDecoration.underline : null);
}

TextStyle hiText() {
  return TextStyle(
      fontFamily: fontName,
      color: hintColor,
      fontSize: 14,
      fontWeight: FontWeight.w400);
}

TextStyle snackText() {
  return const TextStyle(
      fontFamily: fontName,
      color: secColor,
      fontSize: 14,
      fontWeight: FontWeight.w200);
}

TextStyle smallWhiteText() {
  return const TextStyle(
      fontFamily: fontName,
      color: secColor,
      fontSize: 11,
      fontWeight: FontWeight.w100);
}

TextStyle verysmallText() {
  return TextStyle(
      fontFamily: fontName,
      color: greyColor,
      fontSize: 12,
      //fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w100);
}

String API(String endpoint) {
  String url = "";
  if (endpoint.compareTo("login") == 0) {
    url = "${urlRoot}login.php";
  } else if (endpoint.compareTo("signup") == 0) {
    url = "${urlRoot}create_account.php";
  }
  return url;
}

DateTime myDateFormartted(String date) {
  DateTime parseDate = DateFormat("yyyy-MM-dd HH:mm:ss").parse(date);
  DateTime inputDate = DateTime.parse(parseDate.toString());
  var outputFormat = DateFormat('E, dd-MMM-yy hh:mm a');
  //return DateTime.parse(outputFormat.format(inputDate));
  return (inputDate);
}

String myDateFormart(String date) {
  DateTime parseDate = DateFormat("yyyy-MM-dd HH:mm:ss").parse(date);
  DateTime inputDate = DateTime.parse(parseDate.toString());
  var outputFormat = DateFormat('E, dd-MMM-yy HH:mm a');
  return outputFormat.format(inputDate);
}

String myFormattedDate(String date) {
  DateTime parseDate = DateFormat("yyyy-MM-dd HH:mm:ss").parse(date);
  DateTime inputDate = DateTime.parse(parseDate.toString());
  var outputFormat = DateFormat('E, dd-MMM-yy');
  return outputFormat.format(inputDate);
}

bool isNumber(String em) {
  bool valid = false;
  int groupSize;
  if (isNotString(em)) {
    groupSize = int.parse(em);
    if (groupSize >= 2) {
      valid = true;
    }
  }
  return valid;
}

bool isNotString(String s) {
  if (s == null) {
    return false;
  }
  return int.tryParse(s) != null;
}

bool isDecimalNumber(String em) {
  String p = "^[0-9]+[0-9.]*\$";
  RegExp regExp = RegExp(p);
  return regExp.hasMatch(em);
}

bool isEmail(String em) {
  String p =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

  RegExp regExp = RegExp(p);

  return regExp.hasMatch(em);
}

bool validateMobile(String value) {
  String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
  RegExp regExp = RegExp(pattern);
  if (value.isEmpty) {
    return false;
  } else if (!regExp.hasMatch(value)) {
    return false;
  }
  return true;
}

Widget actionButton(String label, IconData icon, VoidCallback action,
    [double width = 125]) {
  return InkWell(
    onTap: action,
    child: Container(
      height: 30,
      width: width,
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [priColor, priColor]),
          border: Border.all(
            color: priColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
            ),
            const SizedBox(
              width: 5.0,
            ),
            Text(label, style: labelWhiteSmallerText()),
          ],
        ),
      ),
    ),
  );
}

Widget adminActionButton(String label, IconData icon, VoidCallback action,
    [double width = 125]) {
  return InkWell(
    onTap: action,
    child: Container(
      height: 30,
      width: width,
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [adminColor, adminColor]),
          border: Border.all(
            color: adminColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
            ),
            const SizedBox(
              width: 5.0,
            ),
            Text(label, style: labelWhiteSmallerText()),
          ],
        ),
      ),
    ),
  );
}

Widget myButton(
    String label, double height, double width, VoidCallback operation,
    [bool isVisible = true]) {
  return Visibility(
    visible: isVisible,
    child: ElevatedButton(
      onPressed: operation,
      style: ElevatedButton.styleFrom(
        primary: priColor,
        elevation: 2,
        padding: EdgeInsets.symmetric(horizontal: width, vertical: height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Text(
        label,
        style: labelWhiteSmallerText(),
      ),
    ),
  );
}

Widget mySpace([double height = 10]) {
  return SizedBox(
    height: height,
  );
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}

Widget buildTextField(IconData icon, String hintText, bool isPassword,
    TextInputType input, TextEditingController txtController,
    [int lines = 1]) {
  return Padding(
    padding: const EdgeInsets.all(2.0),
    child: TextField(
      autofocus: false,
      maxLines: lines,
      style: mainText(),
      controller: txtController,
      obscureText: isPassword,
      keyboardType: input,
      decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            size: 20,
            color: priColor,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: inactiveColor!),
            borderRadius: const BorderRadius.all(
              Radius.circular(5.0),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: priColor),
            borderRadius: const BorderRadius.all(
              Radius.circular(5.0),
            ),
          ),
          contentPadding: const EdgeInsets.all(0),
          hintText: hintText,
          hintStyle: hiText()),
    ),
  );
}

Widget buildTextFieldAction(
    IconData icon,
    String hintText,
    bool isPassword,
    TextInputType input,
    TextEditingController txtController,
    VoidCallback action,
    [int lines = 1]) {
  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: TextField(
      autofocus: false,
      maxLines: lines,
      style: mainText(),
      controller: txtController,
      obscureText: isPassword,
      keyboardType: input,
      decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
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
          hintText: hintText,
          hintStyle: hiText()),
    ),
  );
}

Widget buildCodeTextField(IconData icon, String hintText, bool isPassword,
    TextInputType input, TextEditingController txtController,
    [int lines = 1, bool toUpper = false]) {
  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: TextField(
      maxLines: lines,
      style: mainText(),
      controller: txtController,
      obscureText: isPassword,
      keyboardType: input,
      inputFormatters: [
        UpperCaseTextFormatter(),
      ],
      decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
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
          hintText: hintText,
          hintStyle: hiText()),
    ),
  );
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

Widget myDivider([double thickness = 4]) {
  return Divider(
    color: priAccentColor,
    thickness: thickness,
    indent: 15,
    endIndent: 15,
  );
}

String forCurrency(var num) {
  final formatCurrency = NumberFormat.currency(symbol: 'KES ');
  return formatCurrency.format(num);
}

String forCurrencyString(String num) {
  try {
    final formatCurrency = NumberFormat.currency(symbol: 'KES ');
    return formatCurrency.format(double.parse(num));
  } on FormatException {
    return "KES 0.00";
  }
}

String getCurrentMonth() {
  List months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'January',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  var now = DateTime.now();
  var currentMon = now.month;
  return (months[currentMon - 1].toString().toUpperCase());
}

String getLoanID(userFirstName, userLastName) {
  String firstLetter = userFirstName.toString().substring(0, 1);
  String secondLetter = userLastName.toString().substring(0, 1);
  var now = DateTime.now();
  var currentMon = now.month;
  var currentMilliSecond = now.millisecond;
  return "$firstLetter$secondLetter-$currentMon$currentMilliSecond";
}

class Prefs {
  Future addStringToSF(String key, String val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, val);
  }

  Future<String?> getStringValuesSF(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final image = prefs.getString(key);
    return image;
  }

  Future addBooleanToSF(String key, bool val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, val);
  }

  Future saveLoggedUser(LoggedInUser user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("phone", user.phone);
    await prefs.setString("fname", user.fname);
    await prefs.setString("lname", user.lname);
    await prefs.setString("image", user.image);
  }

  Future<bool> saveClickedGroup(ClickedGroup group) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("groupName", group.groupName);
    await prefs.setString("groupCode", group.groupCode);
    await prefs.setString("role", group.userRoleInGroup);
    await prefs.setString("userActive", group.userActiveInGroup);
    await prefs.setString("groupImage", group.groupImage);
    await prefs.setBool("isAlertAll",
        group.alertsToAll.toString().compareTo('1') == 0 ? true : false);
    await prefs.setBool("isExpenseModule",
        group.expensesModule.toString().compareTo('1') == 0 ? true : false);
    await prefs.setBool("isFinesModule",
        group.finesModule.toString().compareTo('1') == 0 ? true : false);
    await prefs.setBool("isLoansModule",
        group.loansModule.toString().compareTo('1') == 0 ? true : false);
    await prefs.setBool(
        "isMembershipFee",
        group.membershipFeeModule.toString().compareTo('1') == 0
            ? true
            : false);
    await prefs.setBool("adminRecords",
        group.isAdminRecords.toString().compareTo('1') == 0 ? true : false);
    await prefs.setBool("accessreports",
        group.isAccessReports.toString().compareTo('1') == 0 ? true : false);
    await prefs.setBool(
        "contributionEvents",
        group.isEventsContribution.toString().compareTo('1') == 0
            ? true
            : false);
    await prefs.setBool("isDownloadReport",
        group.isDownloadReport.toString().compareTo('1') == 0 ? true : false);
    await prefs.setBool("isShareCapital",
        group.isShareCapital.toString().compareTo('1') == 0 ? true : false);
    await prefs.setBool("isIncomeModule",
        group.isIncomeModule.toString().compareTo('1') == 0 ? true : false);
    return true;
  }

  Future<ClickedGroup> getClickedGroup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final groupName = prefs.getString('groupName');
    final groupCode = prefs.getString('groupCode');
    final role = prefs.getString('role');
    final userActive = prefs.getString('userActive');
    final groupImage = prefs.getString('groupImage');
    final isAlertAll = prefs.getBool('isAlertAll');
    final isExpenseModule = prefs.getBool('isExpenseModule');
    final isFinesModule = prefs.getBool('isFinesModule');
    final isLoansModule = prefs.getBool('isLoansModule');
    final isMembershipFeeModule = prefs.getBool('isMembershipFee');
    final isAdminRecords = prefs.getBool('adminRecords');
    final isAccessReports = prefs.getBool('accessreports');
    final isEventsContribution = prefs.getBool('contributionEvents');
    final isDownloadReports = prefs.getBool('isDownloadReport');
    final isShareCapital = prefs.getBool('isShareCapital');
    final isIncomeModule = prefs.getBool('isIncomeModule');

    ClickedGroup clickedGroup = ClickedGroup(
      groupCode,
      groupName,
      role,
      userActive,
      groupImage,
      isAlertAll,
      isLoansModule,
      isExpenseModule,
      isMembershipFeeModule,
      isFinesModule,
      isAdminRecords,
      isAccessReports,
      isEventsContribution,
      isDownloadReports,
      isShareCapital,
      isIncomeModule,
    );
    return clickedGroup;
  }

  Future<bool?> getBooleanValuesSF(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final val = prefs.getBool(key);
    return val ?? false;
  }

  Future<LoggedInUser> getLoggedUSer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final fname = prefs.getString('fname');
    final lname = prefs.getString('lname');
    final phone = prefs.getString('phone');
    final image = prefs.getString('image');
    final role = prefs.getString('role');
    LoggedInUser loggedInUser = LoggedInUser(fname, lname, phone, image);
    return loggedInUser;
  }
}

class Debouncer {
  int milliseconds = 90;
  late VoidCallback action;
  late Timer _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class DialogBuilder {
  DialogBuilder(this.context);

  final BuildContext context;

  void showLoadingIndicator(String text, String header) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              backgroundColor: secColor,
              content: LoadingIndicator(text: text, header: header),
            ));
      },
    );
  }

  void hideOpenDialog() {
    Navigator.of(context).pop();
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({this.text = '', this.header = ''});

  final String text;
  final String header;

  @override
  Widget build(BuildContext context) {
    var displayedText = text;
    var headerText = header;
    return Container(
        padding: const EdgeInsets.all(16),
        color: transColor,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _getLoadingIndicator(),
              _getHeading(context, headerText),
              _getText(displayedText)
            ]));
  }

  Padding _getLoadingIndicator() {
    return Padding(
        child: Container(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: priColor,
            )),
        padding: const EdgeInsets.only(bottom: 16));
  }

  Widget _getHeading(context, String headerText) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          headerText,
          style: widgetTitleText(),
          textAlign: TextAlign.center,
        ));
  }

  Text _getText(String displayedText) {
    return Text(
      displayedText,
      style: mainText(),
      textAlign: TextAlign.center,
    );
  }
}

class InternetCheck {
  Future<bool> checkInternetConnection(String url) async {
    try {
      final response = await InternetAddress.lookup(url);
      if (response.isNotEmpty) {
        _isConnected = true;
      }
    } on SocketException catch (err) {
      _isConnected = false;
    }
    return _isConnected;
  }
}

class Resource<T> {
  final String url;
  T Function(Response response) parse;

  Resource({required this.url, required this.parse});
}

class Webservice {
  Future<T> load<T>(Resource<T> resource) async {
    final response = await http.get(Uri.parse(resource.url));
    if (response.statusCode == 200) {
      return resource.parse(response);
    } else {
      throw Exception('Failed to load data! ${response.statusCode}');
    }
  }
}

class DateFormatter {
  DateFormatter();

  String getVerboseDateTimeRepresentation(DateTime dateTime) {
    DateTime now = DateTime.now();
    DateTime justNow = now.subtract(const Duration(minutes: 1));
    DateTime localDateTime = dateTime.toLocal();

    if (!localDateTime.difference(justNow).isNegative) {
      return 'Just now';
    }

    String roughTimeString = DateFormat('jm').format(dateTime);
    //String roughTimeString = DateFormat('EE, dd-MMM-yy').format(dateTime);
    if (localDateTime.day == now.day &&
        localDateTime.month == now.month &&
        localDateTime.year == now.year) {
      return roughTimeString;
    }

    DateTime yesterday = now.subtract(const Duration(days: 1));

    if (localDateTime.day == yesterday.day &&
        localDateTime.month == now.month &&
        localDateTime.year == now.year) {
      return 'Yesterday,  $roughTimeString';
    }

    if (now.difference(localDateTime).inDays < 4) {
      String weekday = DateFormat(
        'EEEE',
      ).format(localDateTime);

      return '$weekday, $roughTimeString';
    }

    return '${DateFormat(
      'EE, dd-MMM-yy',
    ).format(dateTime)}, $roughTimeString';
  }
}
