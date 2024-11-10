import 'dart:convert';

class HistoryModel {
  final String epubName;
  final String coverImage;
  final DateTime lastViewDate;
  final int lastViewIndex;
  final String epubFilePath;

  HistoryModel({
    required this.epubName,
    required this.coverImage,
    DateTime? lastViewDate,
    required this.lastViewIndex,
    required this.epubFilePath,
  }) : lastViewDate = lastViewDate ?? DateTime.now();

  // 빈 객체를 반환하는 기본 생성자
  HistoryModel.empty()
      : epubName = '',
        coverImage = '',
        lastViewDate = DateTime.now(),
        lastViewIndex = 0,
        epubFilePath = '';

  // JSON 데이터를 HistoryModel 객체로 변환하는 팩토리 메서드
  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    final historyJson = jsonDecode(map['history_json']);
    return HistoryModel(
      epubName: map['epub_name'] as String,
      coverImage: map['cover_image'] as String,
      lastViewDate: DateTime.parse(map['last_view_date'] as String),
      lastViewIndex: historyJson['last_view_index'] as int,
      epubFilePath: historyJson['epub_file_path'] as String,
    );
  }

  // HistoryModel 객체를 JSON 데이터로 변환하는 메서드
  Map<String, dynamic> toMap() {
    final historyJson = jsonEncode({
      'last_view_index': lastViewIndex,
      'epub_file_path': epubFilePath,
    });
    return {
      'epub_name': epubName,
      'cover_image': coverImage,
      'last_view_date': lastViewDate.toIso8601String(),
      'history_json': historyJson,
    };
  }

  // copyWith 메소드
  HistoryModel copyWith({
    String? epubName,
    String? coverImage,
    DateTime? lastViewDate,
    int? lastViewIndex,
    String? epubFilePath,
  }) {
    return HistoryModel(
      epubName: epubName ?? this.epubName,
      coverImage: coverImage ?? this.coverImage,
      lastViewDate: lastViewDate ?? this.lastViewDate,
      lastViewIndex: lastViewIndex ?? this.lastViewIndex,
      epubFilePath: epubFilePath ?? this.epubFilePath,
    );
  }
}
