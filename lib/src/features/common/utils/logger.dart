import 'package:logger/logger.dart';

// 전역 Logger 인스턴스 생성
final Logger logger = Logger(
  level: Level.debug, // 기본 로그 레벨 설정
  printer: PrettyPrinter(), // 출력 형식 설정 (선택 사항)
);
