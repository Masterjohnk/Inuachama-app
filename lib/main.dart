import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inuachama/helpers/certs.dart';
import 'package:inuachama/util/configurations.dart';
import 'package:inuachama/util/routes.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_wrapper.dart';
import 'package:responsive_framework/utils/scroll_behavior.dart';

void main() async {

  //SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
  HttpOverrides.global = MyHttpOverrides();
}

ThemeData _darkTheme = ThemeData(

    /// accentColor: adminColor,
    brightness: Brightness.dark,
    primaryColor: Colors.amber,
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.amber,
      disabledColor: Colors.grey,
    ));

ThemeData _lightTheme = ThemeData(
    //accentColor: adminColor,
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.blue,
      disabledColor: Colors.grey,
    ));

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String notMessage;
  late String notTitle;
  late String notificationText;
  final RxBool _isLightTheme = true.obs;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: priColor,
    ));
    Get.changeThemeMode(
      _isLightTheme.value ? ThemeMode.light : ThemeMode.dark,
    );
    return GetMaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      getPages: Routes.routes,
      builder: (context, widget) => ResponsiveWrapper.builder(
        ClampingScrollWrapper.builder(context, widget!),
        breakpoints: const [
          ResponsiveBreakpoint.resize(350, name: MOBILE),
          ResponsiveBreakpoint.autoScale(600, name: TABLET),
          ResponsiveBreakpoint.resize(800, name: DESKTOP),
          ResponsiveBreakpoint.autoScale(1700, name: 'XL'),
        ],
      ),
    );
  }
}
