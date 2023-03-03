import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glyph/views/contact_overview.dart';

import '../constants/colors.dart';
import '../controllers/wrapper_controller.dart';
import 'navigation/my_bottom_navigation_bar.dart';

class IndexPage extends StatelessWidget {
  const IndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: kBgGradient),
      child: GetBuilder<WrapperController>(
        init: WrapperController(),
        builder: (s) => Scaffold(
          extendBody: true,
          appBar: AppBar(
            title: Text(s.pageIndexTitle),
            actions: [],
          ),
          body: PageView.builder(
            onPageChanged: (page) {
              s.onItemTapped(page);
            },
            controller: s.pageController,
            itemCount: 4,
            itemBuilder: (BuildContext context, int index) {
              return [
                ContactOverView(),
                ContactOverView(),
                ContactOverView(),
                ContactOverView()
              ][index];
            },
          ),
          resizeToAvoidBottomInset: false,
          //bottomNavigationBar: MyBottomNavigationBar(),
        ),
      ),
    );
  }
}
