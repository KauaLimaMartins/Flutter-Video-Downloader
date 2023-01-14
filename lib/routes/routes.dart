import 'package:get/get.dart';
import 'package:video_downloader/app/ui/screens/downloads/downloads_screen.dart';
import 'package:video_downloader/app/ui/screens/home/home_screen.dart';

class Routes {
  static String home = "/home";
  static String downloads = "/downloads";
}

class AppRoutes {
  static List<GetPage> getPages = [
    GetPage(name: Routes.home, page: () => const HomeScreen()),
    GetPage(name: Routes.downloads, page: () => const DownloadsScreen()),
  ];
}
