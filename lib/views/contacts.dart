import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

import '../controllers/main_controller.dart';

class ContactPage extends StatelessWidget {
  final MainControlller c = Get.put(MainControlller());
  ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: GetX<MainControlller>(builder: (controller) {
      return Column(
        children: [
          const SizedBox(
            height: 80,
          ),
          Text(controller.contacts.length.toString()),
          SizedBox(
            height: 700,
            child: ListView.builder(
                itemCount: controller.contacts.length,
                itemBuilder: ((context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        color: Colors.green,
                        child: Text(controller.contacts.keys.elementAt(index))),
                  );
                })),
          ),
        ],
      );
    }));
  }
}
