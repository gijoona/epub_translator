import 'dart:convert';

import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:logger/logger.dart';
import 'package:xml/xml.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';

class Utils {
  static final Logger logger = Logger();

  static String getImageAsBase64(EpubByteContentFile image) {
    final bytes = image.Content ?? [];
    return 'data:image/png;base64,${base64Encode(bytes)}';
  }

  static Future<Image?> loadAssetAsImage(String assetPath) async {
    try {
      // Load asset as byte data
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();

      // Decode image
      final Image? image = decodeImage(bytes);
      return image;
    } catch (e) {
      logger.e('Error loading asset: $e');
      return null;
    }
  }

  // EPUB 파일에서 표지 이미지를 가져오는 메서드
  static Future<String?> extractCoverImageAsBase64(String epubFilePath) async {
    try {
      // EPUB 파일 열기
      final epubFile = File(epubFilePath);
      if (!epubFile.existsSync()) {
        logger.e('EPUB 파일이 존재하지 않습니다.');
        return null;
      }

      // EPUB 파일을 읽고 압축 해제
      final bytes = await epubFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // container.xml 파일 찾기
      final containerFile = archive.files.firstWhere(
        (file) => file.name == 'META-INF/container.xml',
        orElse: () => throw Exception('container.xml 파일을 찾을 수 없습니다.'),
      );

      // container.xml 파싱하여 .opf 파일 경로 추출
      final containerXml =
          XmlDocument.parse(utf8.decode(containerFile.content));
      final rootfileElement = containerXml
          .findAllElements('rootfile')
          .firstWhere((element) =>
              element.getAttribute('media-type') ==
              'application/oebps-package+xml');
      final opfFilePath = rootfileElement.getAttribute('full-path');
      if (opfFilePath == null) {
        throw Exception('.opf 파일 경로를 찾을 수 없습니다.');
      }

      // .opf 파일 찾기
      final opfFile = archive.files.firstWhere(
        (file) => file.name == opfFilePath,
        orElse: () => throw Exception('.opf 파일을 찾을 수 없습니다.'),
      );

      // .opf 파일 파싱하여 표지 이미지 경로 추출
      final opfXml = XmlDocument.parse(utf8.decode(opfFile.content));
      String? metaCoverId = '';
      try {
        metaCoverId = opfXml
            .findAllElements('meta')
            .firstWhere(
              (element) => element.getAttribute('name') == 'cover',
              orElse: () => throw Exception('표지 이미지 Meta정보를 찾을 수 없습니다.'),
            )
            .getAttribute('content');
      } catch (e) {
        logger.e(e);
        metaCoverId = 'cover';
      }

      String? coverHref = '';
      try {
        final coverItem = opfXml.findAllElements('item').firstWhere(
            (element) => element.getAttribute('id') == metaCoverId,
            orElse: () => throw Exception(
                'coverId로 표지 이미지 항목을 찾을 수 없습니다. item에 대한 cover Like 검색을 수행합니다.'));

        coverHref = coverItem.getAttribute('href');
      } catch (e) {
        logger.e(e);

        // <item href="Images/embed0024_HD.jpg" properties="cover-image" id="embed0024_HD" media-type="image/jpeg"/>
        final imageItems = opfXml.findAllElements('item').where((element) =>
            (element.getAttribute('media-type') ?? '').contains('image'));
        final coverItem = imageItems.firstWhere(
          (imgEl) => (imgEl.getAttribute('properties') ?? '').contains('cover'),
          orElse: () => throw Exception('표지 이미지 경로를 찾을 수 없습니다.'),
        );

        coverHref = coverItem.getAttribute('href');
      }

      if (coverHref == null) {
        throw Exception('표지 이미지 경로를 찾을 수 없습니다.');
      }

      // 표지 이미지 파일 찾기
      final coverFile = archive.files.firstWhere(
        (file) => file.name.endsWith(coverHref!),
        orElse: () => throw Exception('표지 이미지 파일을 찾을 수 없습니다.'),
      );

      // 표지 이미지 데이터를 scaleDown 후 Base64로 인코딩
      return base64Encode(scaleDownImage(coverFile));
    } catch (e, st) {
      logger.e('표지 이미지를 가져오는 중 오류 발생: $e');
      logger.d(st);
      return null;
    }
  }

  static List<int> scaleDownImage(ArchiveFile imageFile) {
    Image? image = decodeImage(imageFile.content);
    if (image == null) {
      throw Exception('이미지를 디코딩할 수 없습니다.');
    }

    // 이미지 크기 조정
    Image resizedImage = copyResize(image, width: 100);

    // PNG 포맷으로 인코딩
    return encodePng(resizedImage);
  }
}
