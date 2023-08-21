import 'package:flutter/material.dart';

const double widthMobile = 600;
const double widthTablet = 900;
const double widthDesktop = 1024;

class ResponsiveHelper extends StatelessWidget {
  const ResponsiveHelper(
      {Key? key, required this.mobile, required this.desktop})
      : super(key: key);
  final Widget mobile;
  final Widget desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= widthDesktop) {
          return desktop;
        } else {
          return mobile;
        }
      },
    );
  }
}
