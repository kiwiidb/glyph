import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';

import 'package:get/get.dart';
import 'package:glyph/controllers/auth_controller.dart';
import 'package:glyph/controllers/contact_page_controller.dart';
import 'package:glyph/models/nostr_profile.dart' as nostr_models;
import 'package:kepler/kepler.dart';
import 'package:nostr/nostr.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';

class NostrControlller extends GetxController {
  final AuthController authController = Get.put(AuthController());
  var loading = true.obs;
  ContactPageController contactPageController =
      Get.put(ContactPageController());
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static final Random _rnd = Random();
  static const String walletPubkey =
      "69effe7b49a6dd5cf525bd0905917a5005ffe480b58eeb8e861418cf3ae760d9";
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

  Future<String> nip04Encrypt(String payload, String pk, String sk) async {
    var ourPrivkey = createECPrivatekey(sk);
    var theirPubkey = createECPubkey(pk);
    final message = utf8.encode(payload);
    // AES-CBC with 128 bit keys and HMAC-SHA256 authentication.
    final algorithm = AesCbc.with256bits(
      macAlgorithm: Hmac.sha256(),
    );
    final secretIV = Kepler.byteSecret(Kepler.strinifyPrivateKey(ourPrivkey),
        Kepler.strinifyPublicKey(theirPubkey));
    final secretKey = await algorithm.newSecretKeyFromBytes(secretIV[0]);
    algorithm.newSecretKey();
    final nonce = algorithm.newNonce();
    final secretBox =
        await algorithm.encrypt(message, secretKey: secretKey, nonce: nonce);
    return "${base64.encode(secretBox.cipherText)}?iv=${base64.encode(nonce)}";
  }

  void fetchNostrFollows(WebSocket ws, String pubkey) async {
// Create a subscription message request with one or many filters
    Request requestWithFilter = Request(getRandomString(10), [
      Filter(authors: [pubkey], kinds: [3]),
      Filter(kinds: [23195, 23196], authors: [walletPubkey])
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
    event.pubkey = authController.keychain.public;
    var recipient = ["p", walletPubkey];
    event.tags = <List<String>>[recipient];
    var encryptedPayload = await nip04Encrypt(
        bolt11, walletPubkey, authController.keychain.private);
    event.content = encryptedPayload;
    event.id = event.getEventId();
    event.sig = event.getSignature(authController.keychain.private);
    walletRelay.add(event.serialize());
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

ECPrivateKey createECPrivatekey(String hexprivkey) {
  BigInt d0 = BigInt.parse(hexprivkey, radix: 16);
  if ((d0 < BigInt.one) || (d0 > (secp256k1.n - BigInt.one))) {
    throw Error();
  }
  return ECPrivateKey(d0, ECCurve_secp256k1());
}

//here we paste in random fiatjaf code and hope it works
ECPublicKey createECPubkey(String hexpubkey) {
  // turn public key into a point (we only get y, but we find out the y)
  BigInt x = bigFromBytes(hex.decode(hexpubkey.padLeft(64, '0')));
  BigInt y;
  y = liftX(x);
  var point = secp256k1.curve.createPoint(x, y);
  return ECPublicKey(point, ECCurve_secp256k1());
}

var secp256k1 = ECDomainParameters("secp256k1");
var curveP = BigInt.parse(
    'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F',
    radix: 16);

// helper methods:
// liftX returns Y for this X
BigInt liftX(BigInt x) {
  if (x >= curveP) {
    throw new Error();
  }
  var ySq = (x.modPow(BigInt.from(3), curveP) + BigInt.from(7)) % curveP;
  var y = ySq.modPow((curveP + BigInt.one) ~/ BigInt.from(4), curveP);
  if (y.modPow(BigInt.two, curveP) != ySq) {
    throw new Error();
  }
  return y % BigInt.two == BigInt.zero /* even */ ? y : curveP - y;
}

BigInt bigFromBytes(List<int> bytes) {
  return BigInt.parse(hex.encode(bytes), radix: 16);
}
