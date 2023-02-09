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
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: controller.pubkeyController,
                  decoration: const InputDecoration(
                    hintText: "npub..",
                  ),
                ),
              ),
              TextButton(
                onPressed: controller.fetchInscriptions,
                child: const Text("Look up inscriptions"),
              ),
              SizedBox(
                height: 750,
                child: GridView.builder(
                  itemCount: controller.utxos.length,
                  itemBuilder: ((context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          controller.getImageUrl(controller.utxos[index]),
                          errorBuilder: (context, error, stackTrace) =>
                              Container(),
                        ),
                      ),
                    );
                  }),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
