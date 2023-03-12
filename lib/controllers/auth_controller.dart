import 'dart:async';
import 'dart:io';

import 'package:convert/convert.dart';
import 'package:dart_bech32/dart_bech32.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController with WidgetsBindingObserver {
  final TextEditingController pubkeyController = TextEditingController();
  var pubkey = "".obs;
  var isLoading = false.obs;
  GetStorage contactBox = GetStorage("identity");

  @override
  void onInit() async {
    var pk = await contactBox.read("identity-pubkey");
    if (pk != "" && pk != null) {
      pubkey.value = pk;
    }
    super.onInit();
  }

  void login(String pubkey) async {
    try {
      var decoded = bech32.decode(pubkey);
      var pubkeyBytes = bech32.fromWords(decoded.words);
      var pubkeyHex = hex.encode(pubkeyBytes);
      await contactBox.write("identity-pubkey", pubkeyHex);
    } catch (e) {
      Get.snackbar("Invalid public key", e.toString(),
          snackPosition: SnackPosition.TOP);
    }
    this.pubkey.value = pubkey;
  }
}
