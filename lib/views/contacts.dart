import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

import '../controllers/main_controller.dart';

class ContactPage extends StatelessWidget {
  final MainControlller c = Get.put(MainControlller());
  ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Glyph"),
          backgroundColor: Colors.black,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GetX<MainControlller>(builder: (controller) {
            return ListView.builder(
                itemCount: controller.contacts.length,
                itemBuilder: ((context, index) {
                  var contact = controller.contacts.values.toList()[index];
                  var pubkey = controller.contacts.keys.toList()[index];
                  Widget img = Container();
                  if (contact.picture == null) {
                    img = Container();
                  } else {
                    if (contact.picture!.contains("data:image/jpeg;base64,")) {
                      img = Image.memory(
                        base64Decode(contact.picture!
                            .replaceAll("data:image/jpeg;base64,", "")),
                        height: 100,
                        width: 100,
                      );
                    }
                    if (contact.picture!.contains("https://")) {
                      img = Image.network(
                        contact.picture!,
                        height: 100,
                        width: 100,
                      );
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () => controller.goToInscriptions(pubkey),
                      child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(16)),
                          height: 100,
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: img,
                              ),
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      contact.name ?? "?",
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )),
                    ),
                  );
                }));
          }),
        ));
  }
}
