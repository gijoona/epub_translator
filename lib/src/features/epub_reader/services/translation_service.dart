import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TranslationService {
  final String apiKey;

  TranslationService({required this.apiKey}) {
    OpenAI.apiKey = apiKey;
  }

  Future<String> translateText(String context, String targetLanguage) async {
    OpenAI.requestsTimeOut = const Duration(minutes: 10);

    // Assistant에게 대화의 방향성을 알려주는 메시지
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          "You are an EPUB file translation expert.",
        ),
      ],
      role: OpenAIChatMessageRole.system,
    );

    // 사용자가 보내는 메시지
    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          'Translate the following text to $targetLanguage: $context',
        ),
      ],
      role: OpenAIChatMessageRole.user,
    );

    final requestMessages = [
      systemMessage,
      userMessage,
    ];

    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: 'gpt-4o-mini',
      messages: requestMessages,
      maxTokens: 500,
    );

    String message =
        chatCompletion.choices.first.message.content![0].text.toString();
    return message;
  }
}

final translationServiceProvider = Provider(
  (ref) => TranslationService(apiKey: 'api-key'),
);
