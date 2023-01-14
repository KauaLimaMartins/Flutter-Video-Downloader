import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_downloader/routes/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showDownloadButtons = false;
  ReceivePort _port = ReceivePort();
  final _searchController = TextEditingController();

  void _searchLink() {
    setState(() {
      _showDownloadButtons = !_showDownloadButtons;
    });
  }

  void _downloadVideo() async {
    var status = await Permission.storage.request();

    if (status.isGranted) {
      final baseStorage = await getExternalStorageDirectory();

      await FlutterDownloader.enqueue(
        url: _searchController.text,
        savedDir: baseStorage!.path,
        showNotification: true,
        openFileFromNotification: true,
        fileName: 'teste33.mp4',
      );
    }
  }

  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      if (status == DownloadTaskStatus.complete) {
        print("Download completed");
      }

      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    _searchController.dispose();

    IsolateNameServer.removePortNameMapping('downloader_send_port');

    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Youtube Downloader"),
        backgroundColor: Colors.deepPurple,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => Get.toNamed(Routes.downloads),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                "Insira o link do vídeo que voce deseja baixar!",
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Link do video',
                suffixIcon: IconButton(
                  onPressed: _searchLink,
                  icon: const Icon(Icons.search),
                  color: Colors.deepPurple,
                ),
              ),
            ),
            Visibility(
              visible: _showDownloadButtons,
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  children: [
                    Text(
                      "Como deseja baixar o video?",
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _downloadVideo,
                            style: const ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll<Color>(
                                Colors.deepPurple,
                              ),
                            ),
                            child: const Text("Música (MP3)"),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          ElevatedButton(
                            onPressed: () => {},
                            style: const ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll<Color>(
                                Colors.deepPurple,
                              ),
                            ),
                            child: const Text("Vídeo (MP4)"),
                          ),
                        ],
                      ),
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
