import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WrapperController extends GetxController {
  final PageController pageController = PageController(initialPage: 0);
  var currentPage = 0.obs;

  onItemTapped(int index) {
    pageController.jumpToPage(index);
    currentPage.value = index;
    update();
  }

  String get pageIndexTitle {
    switch (currentPage.value) {
      case 0:
        return 'Contacts';
      case 1:
        return 'Notifications'.tr;
      default:
        return '';
    }
  }
}
