import 'dart:async';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../models/nostr_profile.dart';

class ContactPageController extends GetxController {
  var currentTabNumber = 0.obs;
  var contacts = <Profile>[].obs;
  GetStorage contactBox = GetStorage();

  @override
  void onInit() async {
    //todo: real stuff
    //await fetchContacts();
    contacts.add(Profile(
        name: "kwinten",
        lightning: "kiwiidb@getalby.com",
        about: "lightning stuff @getalby",
        picture: "https://kwintendebacker.com/images/foto.jpg"));
    contacts.add(Profile(
        name: "bumi",
        lightning: "bumi@getalby.com",
        about:
            "working on getalby.com - a browser extension with lightning and Nostr support",
        picture:
            "https://imgproxy.iris.to/insecure/plain/https://michaelbumann.com/img/profile_small.jpg"));
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
  }

  deleteContact(Profile value) async {
    await contactBox.remove(value.name!);
  }
}
