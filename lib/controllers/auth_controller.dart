import 'dart:async';
import 'dart:io';

import 'package:convert/convert.dart';
import 'package:dart_bech32/dart_bech32.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../models/nostr_profile.dart';

class AuthController extends GetxController with WidgetsBindingObserver {
  final TextEditingController pubkeyController = TextEditingController();
  var pubkey = "".obs;
  var npub = "".obs;
  var isLoading = false.obs;
  var profile = Profile().obs;
  GetStorage accountStorage = GetStorage("identity");

  @override
  void onInit() async {
    var pk = await accountStorage.read("identity-pubkey-hex");
    if (pk != "" && pk != null) {
      pubkey.value = pk;
    }
    var npub = await accountStorage.read("identity-pubkey-npub");
    if (pk != "" && pk != null) {
      this.npub.value = npub;
    }
    super.onInit();
  }

  void login(String pubkey) async {
    try {
      var decoded = bech32.decode(pubkey);
      var pubkeyBytes = bech32.fromWords(decoded.words);
      var pubkeyHex = hex.encode(pubkeyBytes);
      await accountStorage.write("identity-pubkey-hex", pubkeyHex);
      await accountStorage.write("identity-pubkey-npub", pubkey);
      this.pubkey.value = pubkeyHex;
      npub.value = pubkey;
    } catch (e) {
      Get.snackbar("Invalid public key", e.toString(),
          snackPosition: SnackPosition.TOP);
      return;
    }
  }
}
