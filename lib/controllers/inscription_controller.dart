import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:convert/convert.dart';
import 'package:dart_bech32/dart_bech32.dart';
import 'package:glyph/models/bitcoin_transaction.dart';
import 'package:glyph/models/utxo.dart';
import 'package:glyph/views/inscription_list.dart';
import 'package:http/http.dart' as http;
import 'package:nostr/nostr.dart';

import '../models/nostr_profile.dart';

class InscriptionControlller extends GetxController {
  var utxos = List<Utxo>.empty().obs;
  var contacts = <String, Profile>{}.obs;
  var loading = true.obs;
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static final Random _rnd = Random();

  void goToInscriptions(String pubkey) async {
    await fetchInscriptions(pubkey);
    Get.to(() => InscriptionView());
  }

  String getAddressFromPubkey(String pubkey) {
    //damn I don't know what I'm doing
    //var decoded = bech32.decode(pubkey);
    var pubkeyWords = _convertBits(hex.decode(pubkey), 8, 5, true);
    var newList = List<int>.from(pubkeyWords);
    //add segwit version (1: taproot)
    newList.insert(0, 1);
    var newWords = Uint8List.fromList(newList);
    var encoded = bech32m.encode(Decoded(prefix: "bc", words: newWords));
    return encoded;
  }

  Future<void> fetchInscriptions(String pubkey) async {
    var p2tr = getAddressFromPubkey(pubkey);
    print(p2tr);
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
    var utxoMap = parsed.map((e) => Utxo.fromJson(e));
    //var newMap = await Future.wait(
    //    utxoMap.map((utxo) async => await lookupInscription(utxo, 0)));
    return utxoMap.toList();
  }

  Future<Utxo> lookupInscription(Utxo utxo, int attempt) async {
    //check if the tx has an inscription
    //if not, recursively look up it's inputs
    //up to X (let's say 5) levels deep (this needs a real solution)
    //and check if those have inscriptions
    var maxAttempts = 5;
    if (attempt == maxAttempts) {
      return Utxo();
    }
    var uri =
        Uri.parse("https://ordinals.com/inscription/${utxo.txid}i${utxo.vout}");
    var res = await http.get(
      uri,
    );
    if (res.statusCode == 200) {
      //found inscription
      return utxo;
    }
    //look up previous tx from mempool;
    print("looking up prev tx from mempool");
    var url = Uri.parse('https://mempool.space/api/tx/${utxo.txid}');
    res = await http.get(
      url,
    );
    if (res.statusCode != 200) {
      throw Exception('http.get error: statusCode= ${res.statusCode}');
    }
    var parsed = BitcoinTransaction.fromJson(jsonDecode(res.body));
    if (parsed.vin!.isEmpty) {
      return Utxo();
    }
    //call this function again
    return lookupInscription(
        Utxo(txid: parsed.vin![0].txid, vout: parsed.vin![0].vout),
        attempt + 1);
  }

  String getImageUrl(Utxo utxo) {
    return 'https://ordinals.com/content/${utxo.txid}i${utxo.vout}';
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

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}
