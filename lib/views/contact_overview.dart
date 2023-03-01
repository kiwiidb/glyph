import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/cards/app_card.dart';
import '../controllers/contact_controller.dart';
import '../controllers/contact_page_controller.dart';
import '../models/nostr_profile.dart';
import 'contact_pay.dart';

class ContactOverView extends StatelessWidget {
  final ContactController contactController = Get.put(ContactController());
  final ContactPageController contactPageController =
      Get.put(ContactPageController());
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GetX<ContactPageController>(builder: (controller) {
        if (controller.contacts.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 10),
            child: Text("no-contacts".tr),
          );
        }
        return ListView.separated(
            shrinkWrap: true,
            primary: false,
            padding: EdgeInsets.zero,
            itemCount: controller.contacts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              var contact = controller.contacts[i];
              return InkWell(
                onTap: () {
                  contactController.selectedContact.value = contact;
                  contactController.setDescriptionText();
                  Get.to(() => ContactPayView());
                },
                child: ContactWidget(contact: contact, width: width),
              );
            });
      }),
    );
  }
}

class ContactWidget extends StatelessWidget {
  const ContactWidget({
    super.key,
    required this.contact,
    required this.width,
  });

  final Profile contact;
  final double width;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(23.0, 16.0, 23.0, 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.network(
            contact.picture!,
            width: 60,
          ),
          const SizedBox(width: 15.0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name!.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  getSecondRow(contact),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          const Icon(Icons.arrow_forward)
        ],
      ),
    );
  }

  String extractHost(String lnAddress) {
    return lnAddress.replaceAll(RegExp(".*@"), "");
  }

  getSecondRow(Profile contact) {
    return Text(
      //todo
      extractHost(contact.lightning!),
      style: const TextStyle(
        fontSize: 13.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
