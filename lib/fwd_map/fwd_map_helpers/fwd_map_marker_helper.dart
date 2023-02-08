import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show Widget;
import 'package:http/http.dart' as http;
import 'package:screenshot/screenshot.dart';

class FwdMapMarkerHelper {
  static Map<String, Uint8List> cachedWidgets = {};

  static Future<Uint8List> widgetToBytes(Widget widget, {Duration? delay, String? cacheKey}) async {
    if (cachedWidgets.containsKey(cacheKey)) {
      return cachedWidgets[cacheKey]!;
    }

    final bytes = await ScreenshotController().captureFromWidget(
      widget,
      delay: delay ?? const Duration(seconds: 1),
    );

    if (cacheKey != null) {
      cachedWidgets[cacheKey] = bytes;
    }
    return bytes;
  }

  static Future<Uint8List> imageAssetToBytes(String imageAssetPath) async {
    Uint8List bytes = (await rootBundle.load(imageAssetPath)).buffer.asUint8List();
    return bytes;
  }

  static Future<Uint8List> imageNetworkToBytes(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    return response.bodyBytes;
  }
}
