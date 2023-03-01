import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glyph/controllers/inscription_controller.dart';

class InscriptionView extends StatelessWidget {
  InscriptionView({super.key});
  final InscriptionControlller c = Get.put(InscriptionControlller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Glyph"),
      ),
      body: GetX<InscriptionControlller>(builder: (controller) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: GridView.builder(
            itemCount: controller.utxos.length,
            itemBuilder: ((context, index) {
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    controller.getImageUrl(controller.utxos[index]),
                    errorBuilder: (context, error, stackTrace) => Container(),
                  ),
                ),
              );
            }),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
            ),
          ),
        );
      }),
    );
  }
}
