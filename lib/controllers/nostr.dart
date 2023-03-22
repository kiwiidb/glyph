import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:get/get.dart';
import 'package:glyph/controllers/auth_controller.dart';
import 'package:glyph/controllers/contact_page_controller.dart';
import 'package:glyph/models/nostr_profile.dart' as nostr_models;
import 'package:nostr/nostr.dart';

class NostrControlller extends GetxController {
  final AuthController authController = Get.put(AuthController());
  var loading = true.obs;
  ContactPageController contactPageController =
      Get.put(ContactPageController());
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static final Random _rnd = Random();
  static const String walletPubkey = "123hex";
  late WebSocket walletRelay;
  static const defaultRelays = [
    "wss://relay.damus.io",
    "wss://eden.nostr.land",
    "wss://nostr.fmt.wiz.biz",
    "wss://nostr.zebedee.cloud",
    "wss://brb.io"
  ];

  @override
  void onInit() async {
    for (String relay in defaultRelays) {
      try {
        WebSocket ws = await WebSocket.connect(relay);
        if (relay == "wss://relay.damus.io") {
          walletRelay = ws;
        }
        startListenLoop(ws);
        await Future.delayed(const Duration(seconds: 1));
        fetchNostrFollows(ws, authController.pubkey.value);
        fetchProfile(ws, authController.pubkey.value);
      } catch (e) {
        Get.snackbar(
            "Something went wrong", "error ${e.toString()}, relay $relay");
      }
    }

    super.onInit();
  }

  void fetchNostrFollows(WebSocket ws, String pubkey) async {
// Create a subscription message request with one or many filters
    Request requestWithFilter = Request(getRandomString(10), [
      Filter(authors: [pubkey], kinds: [3])
    ]);

    // Send a request message to the WebSocket server
    ws.add(requestWithFilter.serialize());

    // Listen for events from the WebSocket server
  }

  void startListenLoop(WebSocket ws) {
    ws.listen((event) {
      var parsedMsg = Message.deserialize(event).message;
      if (parsedMsg is Event) {
        for (var tag in parsedMsg.tags) {
          if (parsedMsg.kind == 3 && tag.length == 2 && tag[0] == "p") {
            fetchProfile(ws, tag[1]);
          }
        }
        if (parsedMsg.kind == 0) {
          var parsedProfile =
              jsonDecode(parsedMsg.content) as Map<String, dynamic>;
          nostr_models.Profile prf =
              nostr_models.Profile.fromJson(parsedProfile);
          prf.pubkey = parsedMsg.pubkey;
          if (prf.pubkey == authController.pubkey.value) {
            authController.profile.value = prf;
            return;
          }
          if (prf.pubkey != null && prf.name != null) {
            contactPageController.storeContact(prf);
          }
        }
        if (parsedMsg.kind == 23195) {
          Get.snackbar("Succesfully sent payment!", "🚀",
              snackPosition: SnackPosition.TOP);
        }
        if (parsedMsg.kind == 23196) {
          Get.snackbar("Error sending payment", "😥",
              snackPosition: SnackPosition.TOP);
        }
      }
    });
  }

  void sendZap(String bolt11) async {
    var event = Event.partial();
    event.kind = 23194;
    event.createdAt = currentUnixTimestampSeconds();
    var recipient = ["p", walletPubkey];
    event.tags = <List<String>>[recipient];
  }

  void fetchProfile(WebSocket ws, String pubkey) async {
    Request requestWithFilter = Request(getRandomString(10), [
      Filter(authors: [pubkey], kinds: [0])
    ]);

    // Send a request message to the WebSocket server
    ws.add(requestWithFilter.serialize());
  }

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}
