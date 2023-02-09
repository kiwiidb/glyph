import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:convert/convert.dart';
import 'package:dart_bech32/dart_bech32.dart';
import 'package:glyph/models/utxo.dart';
import 'package:http/http.dart' as http;

class MainControlller extends GetxController {
  final TextEditingController pubkeyController = TextEditingController();
  var utxos = List<Utxo>.empty().obs;
  var loading = true.obs;

  String getAddressFromPubkey(String pubkey) {
    //damn I don't know what I'm doing
    var decoded = bech32.decode(pubkey);
    var newList = List<int>.from(decoded.words);
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
