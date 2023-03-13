import 'dart:async';
import 'dart:ffi';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:glyph/controllers/nostr.dart';

import '../models/nostr_profile.dart';

class ContactPageController extends GetxController {
  var currentTabNumber = 0.obs;
  var contacts = <String, Profile>{}.obs;
  GetStorage contactBox = GetStorage('contacts');

  @override
  void onInit() async {
    fetchContacts();
    super.onInit();
  }

  Future<void> fetchContacts() async {
    var keys = contactBox.getKeys();
    for (String key in keys) {
      Map<String, dynamic> cJson = contactBox.read(key);
      contacts[key] = Profile.fromJson(cJson);
    }
  }

  Future<void> storeContact(Profile c) async {
    await contactBox.write(c.pubkey!, c);
    contacts[c.pubkey!] = c;
  }

  deleteContact(Profile value) async {
    await contactBox.remove(value.pubkey!);
  }
}
