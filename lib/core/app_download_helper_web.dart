// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:js' as js;

void downloadApkImpl({String url = '/app/lovecloud.apk', String filename = 'lovecloud.apk'}) {
  try {
    if (js.context.hasProperty('installLoveCloudPwa')) {
      js.context.callMethod('installLoveCloudPwa');
      return;
    }
  } catch (_) {}

  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..target = '_blank';
  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
}

void triggerPwaInstallImpl() {
  try {
    if (js.context.hasProperty('installLoveCloudPwa')) {
      js.context.callMethod('installLoveCloudPwa');
    }
  } catch (_) {}
}
