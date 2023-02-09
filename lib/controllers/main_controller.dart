import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:convert/convert.dart';
import 'package:dart_bech32/dart_bech32.dart';
import 'package:glyph/models/utxo.dart';
import 'package:http/http.dart' as http;
import 'package:nostr/nostr.dart';

class MainControlller extends GetxController {
  final TextEditingController pubkeyController = TextEditingController();
  var utxos = List<Utxo>.empty().obs;
  var loading = true.obs;

  @override
  void onInit() {
    fetchNostrFollows("dummy");
    super.onInit();
  }

  String getAddressFromPubkey(String pubkey) {
    //damn I don't know what I'm doing
    var decoded = bech32.decode(pubkey);
    var newList = List<int>.from(decoded.words);
    //add segwit version (1: taproot)
    newList.insert(0, 1);
    var newWords = Uint8List.fromList(newList);
    var encoded = bech32m.encode(Decoded(prefix: "bc", words: newWords));
    return encoded;
  }

  void fetchInscriptions() async {
    var p2tr = getAddressFromPubkey(pubkeyController.text);
    utxos.value = await fetchUtxos(p2tr);
  }

  Future<List<Utxo>> fetchUtxos(String address) async {
    var url = Uri.parse('https://mempool.space/api/address/$address/utxo');
    var res = await http.get(
      url,
    );
    if (res.statusCode != 200) {
      throw Exception('http.get error: statusCode= ${res.statusCode}');
    }
    var parsed = jsonDecode(res.body) as List;
    return parsed.map((e) => Utxo.fromJson(e)).toList();
  }

  String getImageUrl(Utxo utxo) {
    return 'https://ordinals.com/content/${utxo.txid}i${utxo.vout}';
  }

  void fetchNostrFollows(String pubkey) async {
// Create a subscription message request with one or many filters
    Request requestWithFilter = Request("sdfsdfsdfs", [
      Filter(
        p: ["8c3b267e9db6b0115498cc3efcd187d1474864940ae8ff977826b9d83d205877"],
        kinds: [3],
        limit: 500,
      )
    ]);

    // Connecting to a nostr relay using websocket
    WebSocket webSocket = await WebSocket.connect(
      'wss://brb.io', // or any nostr relay
    );
    // if the current socket fail try another one
    // wss://nostr.sandwich.farm
    // wss://relay.damus.io

    // Send a request message to the WebSocket server
    webSocket.add(requestWithFilter.serialize());

    // Listen for events from the WebSocket server
    print("started listening..");
    await Future.delayed(Duration(seconds: 1));
    webSocket.listen((event) {
      var parsed = Message.deserialize(event) as Event;
      print('Received event: ${parsed.tags}');
    });

    // Close the WebSocket connection
    await webSocket.close();
  }
}

List<int> _convertBits(List<int> data, int from, int to, bool pad) {
  var acc = 0;
  var bits = 0;
  var result = <int>[];
  var maxv = (1 << to) - 1;

  data.forEach((v) {
    if (v < 0 || (v >> from) != 0) {
      throw Exception();
    }
    acc = (acc << from) | v;
    bits += from;
    while (bits >= to) {
      bits -= to;
      result.add((acc >> bits) & maxv);
    }
  });

  if (pad) {
    if (bits > 0) {
      result.add((acc << (to - bits)) & maxv);
    }
  }
  return result;
}
