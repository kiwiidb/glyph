import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/buttons/gradient_button.dart';
import '../components/labeled_text_form_field.dart';
import '../constants/app_constants.dart';
import '../constants/colors.dart';
import '../controllers/contact_controller.dart';
import '../controllers/contact_page_controller.dart';

class ContactPayView extends StatelessWidget {
  final ContactController contactController = Get.put(ContactController());
  final ContactPageController cpc = Get.put(ContactPageController());

  ContactPayView({super.key});
  @override
  Widget build(BuildContext context) {
    var contact = contactController.selectedContact.value;
    Widget addContactButton = Container();

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: kBgGradient),
      child: Scaffold(
        appBar: AppBar(title: const Text('Send Funds')),
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: AppConstants.contentPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'To:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            contact.picture,
                            width: 100,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contact.name!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                extractHost(contact.lud16!),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                        addContactButton
                      ],
                    ),
                    const SizedBox(height: 27.0),
                    LabeledTextFormField(
                      label: 'Amount',
                      controller: contactController.amountController,
                      hintText: '0',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          widthFactor: 0.0,
                          child: Text('EUR '),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 27.0),
                    LabeledTextFormField(
                      controller: contactController.descriptionController,
                      label: 'Description'.tr,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      borderRadius: 10.0,
                    ),
                    const Spacer(),
                    const SizedBox(height: 32),
                    GradientButton(
                      onPressed: () {
                        contactController.fetchInvoice();
                      },
                      text: "send".tr,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String extractHost(String lnAddress) {
  return lnAddress.replaceAll(RegExp(".*@"), "");
}
