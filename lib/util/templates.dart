import 'package:flutter/material.dart';
import 'package:inuachama/util/configurations.dart';
import 'package:get/get.dart';

void showSnackBar(body, [title = appName]) {
  Get.snackbar(title, '',
      icon: const Icon(
        Icons.info_outline_rounded,
        color: secColor,
      ),
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: priColor,
      titleText: Text(title, style: labelWhiteText()),
      messageText: Text(body, style: labelWhiteSmallerText()),
      snackStyle: SnackStyle.FLOATING);
}
