import 'dart:async';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:glyph/controllers/nostr.dart';

import '../models/nostr_profile.dart';

class ContactPageController extends GetxController {
  var currentTabNumber = 0.obs;
  var contacts = <Profile>[].obs;
  GetStorage contactBox = GetStorage();

  @override
  void onInit() async {
    super.onInit();
  }

  Future<void> fetchContacts() async {
    var keys = contactBox.getKeys();
    contacts.removeWhere((element) => true);
    for (String key in keys) {
      var cJson = contactBox.read(key);
      if (cJson is Profile) {
        contacts.add(cJson);
      }
    }
  }

  Future<void> storeContact(Profile c) async {
    await contactBox.write(c.name!, c);
    contacts.add(c);
  }

  deleteContact(Profile value) async {
    await contactBox.remove(value.name!);
  }
}
