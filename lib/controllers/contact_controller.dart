import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

import '../models/nostr_profile.dart';
import '../services/lnurl_pay_service.dart';

class ContactController extends GetxController {
  final TextEditingController searchLNAddressController =
      TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  //final ExchangeRateController appBarController =
  //    Get.put(ExchangeRateController());
  final LnUrlPayService lnUrlPayService = Get.put(LnUrlPayService());
  var foundUsers = <Profile>[].obs;
  var searching = false.obs;
  var selectedContact = Profile().obs;

  void setDescriptionText() {
    descriptionController.text = "Payment to ${selectedContact.value.name!}";
  }

  @override
  void onInit() async {
    searchLNAddressController.addListener(() async {
      if (searchLNAddressController.text.isEmpty) {
        foundUsers.removeWhere((element) => true);
      }
    });
    super.onInit();
  }

  void fetchInvoice() async {
    double amt;
    try {
      amt = double.parse(amountController.text);
    } catch (e) {
      Get.snackbar("amount-too-small".tr, "Please fill in an amount.",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (amt <= 0) {
      Get.snackbar("amount-too-small".tr, "Please fill in an amount.",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    //var btcPrice = appBarController.priceInfo.value.bitcoinPriceInEuro;
    //var satAmt = ((amt / btcPrice) * 1e8).round();
    //Todo
    var satAmt = amt.round();
    //var pay = await apiService.fetchInvoice(satAmt,
    //    selectedContact.value.flitzDepositId, descriptionController.text);
    var first =
        await lnUrlPayService.lnAddressCall(selectedContact.value.lud16!);
    var pay = await lnUrlPayService.fetchInvoice(first.callback!, satAmt);
    //todo check amount and hash
    launchLnUrl("lightning:${pay.pr!}");
  }

  launchLnUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Get.snackbar(
          "Could not open LN link. Please install one of the supported LN wallets on your device.",
          "",
          snackPosition: SnackPosition.TOP);
    }
  }

  searchLNAddress() async {
    if (!(searchLNAddressController.text.contains("@")) ||
        !(searchLNAddressController.text.contains("."))) {
      Get.snackbar("Wrong format", "Please enter a valid LN Address",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    //todo: stuff
  }

  getName(String text) {
    return text.replaceAll(RegExp("@.*"), "");
  }

  String extractImageString(String metadata) {
    final result = json.decode(metadata);
    if (result == null) {
      return "";
    }
    for (dynamic value in result) {
      if (value.length != 2) {
        continue;
      }
      if ((value[0] == "image/png;base64") ||
          (value[0] == "image/jpeg;base64")) {
        return value[1];
      }
    }
    return "";
  }
}
