import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glyph/app_theme.dart';
import 'package:glyph/views/index_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme().theme,
      home: const IndexPage(),
    );
  }
}
