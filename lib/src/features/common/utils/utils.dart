import 'dart:convert';

import 'package:epubx/epubx.dart';

class Utils {
  static String getImageAsBase64(EpubByteContentFile image) {
    final bytes = image.Content ?? [];
    return 'data:image/png;base64,${base64Encode(bytes)}';
  }
}
