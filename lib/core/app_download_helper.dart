import 'app_download_helper_stub.dart'
    if (dart.library.html) 'app_download_helper_web.dart';

class AppDownloadHelper {
  static void downloadApk({String url = '/app/lovecloud.apk', String filename = 'lovecloud.apk'}) {
    downloadApkImpl(url: url, filename: filename);
  }
}
