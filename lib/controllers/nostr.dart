import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:convert/convert.dart';
import 'package:dart_bech32/dart_bech32.dart';
import 'package:glyph/controllers/auth_controller.dart';
import 'package:glyph/controllers/contact_page_controller.dart';
import 'package:glyph/models/bitcoin_transaction.dart';
import 'package:glyph/models/utxo.dart';
import 'package:glyph/views/inscription_list.dart';
import 'package:http/http.dart' as http;
import 'package:nostr/nostr.dart';

import '../models/nostr_profile.dart';

class NostrControlller extends GetxController {
  final AuthController authController = Get.put(AuthController());
  var loading = true.obs;
  late WebSocket ws;
  ContactPageController contactPageController =
      Get.put(ContactPageController());
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static final Random _rnd = Random();

  @override
  void onInit() async {
    // Connecting to a nostr relay using websocket
    ws = await WebSocket.connect(
      'wss://relay.damus.io', // or any nostr relay
    );
    startListenLoop();
    await Future.delayed(const Duration(seconds: 1));
    fetchNostrFollows(authController.pubkey.value);
    super.onInit();
  }

  void fetchNostrFollows(String pubkey) async {
// Create a subscription message request with one or many filters
    Request requestWithFilter = Request(getRandomString(10), [
      Filter(authors: [pubkey], kinds: [3])
    ]);

    // Send a request message to the WebSocket server
    ws.add(requestWithFilter.serialize());

    // Listen for events from the WebSocket server
    print("updating contacts from nostr..");
  }

  void startListenLoop() {
    print("start listen loop");
    ws.listen((event) {
      var parsedMsg = Message.deserialize(event).message;
      if (parsedMsg is Event) {
        for (var tag in parsedMsg.tags) {
          if (parsedMsg.kind == 3 && tag.length == 2 && tag[0] == "p") {
            fetchProfile(tag[1]);
          }
        }
        if (parsedMsg.kind == 0) {
          var parsedProfile =
              jsonDecode(parsedMsg.content) as Map<String, dynamic>;
          Profile prf = Profile.fromJson(parsedProfile);
          prf.pubkey = parsedMsg.pubkey;
          if (prf.lud16 != null && prf.pubkey != null && prf.name != null) {
            contactPageController.storeContact(prf);
          }
        }
      }
    });
  }

  void fetchProfile(String pubkey) async {
    Request requestWithFilter = Request(getRandomString(10), [
      Filter(authors: [pubkey], kinds: [0])
    ]);

    // Send a request message to the WebSocket server
    ws.add(requestWithFilter.serialize());
  }

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}
