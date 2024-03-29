import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glyph/controllers/nostr.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

import '../models/nostr_profile.dart';
import '../models/rate.dart';
import '../services/lnurl_pay_service.dart';

class ContactController extends GetxController {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final LnUrlPayService lnUrlPayService = Get.put(LnUrlPayService());
  final NostrControlller nostrControlller = Get.put(NostrControlller());
  var searching = false.obs;
  var selectedContact = Profile().obs;
  Rate rate = Rate();

  void setDescriptionText() {
    descriptionController.text = "Payment to ${selectedContact.value.name!}";
  }

  @override
  void onInit() async {
    rate = await lnUrlPayService.getRate();
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
    var satAmt = ((amt / rate.rateFloat!) * 1e8).round();
    var first =
        await lnUrlPayService.lnAddressCall(selectedContact.value.lud16!);
    var pay = await lnUrlPayService.fetchInvoice(first.callback!, satAmt);
    nostrControlller.sendZap(pay.pr!);
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
