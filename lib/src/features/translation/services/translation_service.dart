import 'package:dart_openai/dart_openai.dart';
import 'package:epub_translator/src/db/provider/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TranslationService {
  final String model;
  final String apiKey;
  final String prompt;
  final int maxTokens = 1000;

  TranslationService({
    required this.model,
    required this.apiKey,
    required this.prompt,
  }) {
    OpenAI.apiKey = apiKey;
  }

  Future<String> translateText(String context, String targetLanguage) async {
    OpenAI.requestsTimeOut = const Duration(minutes: 10);

    // Assistant에게 대화의 방향성을 알려주는 메시지
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
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
      model: model,
      messages: requestMessages,
      maxTokens: maxTokens,
    );

    String message =
        chatCompletion.choices.first.message.content![0].text.toString();
    return message;
  }
}

final translationServiceProvider = Provider(
  (ref) {
    final config = ref.watch(configProvider).value!;

    return TranslationService(
      model: config['OPENAI_API_MODEL'] ?? '',
      apiKey: config['OPENAI_API_KEY'] ?? '',
      prompt: config['TRANSLATION_PROMPT'] ?? '',
    );
  },
);
