// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void downloadApkImpl({String url = '/app/lovecloud.apk', String filename = 'lovecloud.apk'}) {
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..target = '_blank';
  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
}
