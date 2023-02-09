import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glyph/controllers/main_controller.dart';

class Home extends StatelessWidget {
  Home({super.key});
  final MainControlller c = Get.put(MainControlller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetX<MainControlller>(builder: (controller) {
        return GridView.builder(
          itemCount: controller.utxos.length,
          itemBuilder: ((context, index) {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  controller.getImageUrl(controller.utxos[index]),
                ),
              ),
            );
          }),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
          ),
        );
      }),
    );
  }
}
