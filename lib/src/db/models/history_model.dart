class HistoryModel {
  final String epubName;
  final String coverImage;
  final DateTime lastViewDate;
  final String historyJson;

  HistoryModel({
    required this.epubName,
    required this.coverImage,
    required this.lastViewDate,
    required this.historyJson,
  });

  // JSON 데이터를 HistoryModel 객체로 변환하는 팩토리 메서드
  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      epubName: map['epub_name'] as String,
      coverImage: map['cover_image'] as String,
      lastViewDate: DateTime.parse(map['last_view_date'] as String),
      historyJson: map['history_json'] as String,
    );
  }

  // HistoryModel 객체를 JSON 데이터로 변환하는 메서드
  Map<String, dynamic> toMap() {
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
    String? historyJson,
  }) {
    return HistoryModel(
      epubName: epubName ?? this.epubName,
      coverImage: coverImage ?? this.coverImage,
      lastViewDate: lastViewDate ?? this.lastViewDate,
      historyJson: historyJson ?? this.historyJson,
    );
  }
}
