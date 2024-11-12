import 'package:logger/logger.dart';

/*
  logger 패키지 로그 레벨별 설명:
  Level.verbose

  설명: 모든 로그 메시지를 포함한 가장 낮은 레벨입니다.
  사용 예: 디버깅 중 모든 세부 정보를 보고 싶을 때 사용.
  출력: verbose, debug, info, warning, error, wtf 전부 출력.
  Level.debug

  설명: 디버깅 목적으로 상세한 로그 정보를 출력합니다.
  사용 예: 코드의 동작을 분석하거나 문제를 추적할 때.
  출력: debug, info, warning, error, wtf 출력.
  Level.info

  설명: 일반 정보성 메시지를 나타냅니다.
  사용 예: 상태 업데이트나 애플리케이션의 주요 동작을 기록할 때.
  출력: info, warning, error, wtf 출력.
  Level.warning

  설명: 경고 메시지를 출력하며, 애플리케이션의 잠재적 문제를 나타냅니다.
  사용 예: 잘못된 사용이나 경미한 문제를 나타낼 때.
  출력: warning, error, wtf 출력.
  Level.error

  설명: 심각한 문제를 나타내며, 애플리케이션의 오류 상황을 기록합니다.
  사용 예: 예외 상황, 오류가 발생했을 때.
  출력: error, wtf 출력.
  Level.wtf (What a Terrible Failure)

  설명: 가장 심각한 문제를 나타내며, 치명적인 에러를 기록할 때 사용합니다.
  사용 예: 예기치 않은 치명적인 실패가 발생했을 때.
  출력: wtf 출력.
  Level.nothing

  설명: 로그를 비활성화하며, 어떤 로그도 출력하지 않습니다.
  사용 예: 로그 출력을 모두 중단할 때.
  출력: 없음.
*/

// 전역 Logger 인스턴스 생성
final Logger logger = Logger(
  level: Level.trace, // 기본 로그 레벨 설정
  printer: PrettyPrinter(), // 출력 형식 설정 (선택 사항)
);
