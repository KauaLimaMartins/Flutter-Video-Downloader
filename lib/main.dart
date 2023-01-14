import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:video_downloader/routes/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterDownloader.initialize();

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.home,
      getPages: AppRoutes.getPages,
    ),
  );
}
