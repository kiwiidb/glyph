import 'dart:convert';

import 'package:get/get.dart';
import 'package:glyph/models/utxo.dart';
import 'package:http/http.dart' as http;

class MainControlller extends GetxController {
  var pubkey =
      "npub13sajvl5ak6cpz4ycesl0e5v869r5sey5pt50l9mcy6uas0fqtpmscth4np";
  var receiveAddress =
      "bc1p3sajvl5ak6cpz4ycesl0e5v869r5sey5pt50l9mcy6uas0fqtpmsmtt7mr";
  var utxos = List<Utxo>.empty().obs;
  var loading = true.obs;

  @override
  void onInit() async {
    super.onInit();
    utxos.value = await fetchUtxos(receiveAddress);
    loading.value = false;
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
