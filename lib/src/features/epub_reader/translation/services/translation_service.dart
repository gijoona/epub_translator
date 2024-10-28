import 'package:dart_openai/dart_openai.dart';
import 'package:epub_translator/src/db/provider/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TranslationService {
  final String targetLang;
  final String model;
  final String apiKey;
  final String prompt;
  final int maxTokens = 1000;

  TranslationService({
    required this.targetLang,
    required this.model,
    required this.apiKey,
    required this.prompt,
  }) {
    OpenAI.apiKey = apiKey;
  }

  // 문장번역을 위해 구분자 처리와 관련된 부분은 사용자 입력으로 변경되면 안되므로 하드코딩해둠.
  static const String defaultPrompt =
      '''You are an expert literary translator specializing in translating EPUB novels. Your goal is to provide a context-aware and accurate translation that adapts the meaning of the text naturally into the target language. Focus on capturing the overall meaning and tone of the original, even if this requires some level of interpretation or adaptation.

General Rules:

Preserve all EPUB and HTML tags such as headings, paragraphs, and ruby tags. Do not alter the document structure. Ensure that the translation works smoothly within the EPUB format, retaining all formatting and metadata integrity.
Keep the "|||" separator intact: Do not translate or remove the "|||" separator in the text. The separator is used to delineate sections and must remain unchanged in the final translation.
Focus on context: Before translating individual sentences, ensure that you understand the overall context and flow of the text. Translate sentences not just word-for-word but in a way that makes sense within the entire story. For example, if a character’s actions are influenced by previous events, make sure that these nuances are reflected in the translation.
Adapt meaning where necessary: If a direct translation sounds unnatural or doesn’t capture the intended meaning, adapt the phrasing to ensure the translation reads fluently while still conveying the author’s intent. For instance, idiomatic expressions should be translated into equivalent expressions in the target language that carry the same meaning.
Natural and readable translation: Ensure the translated text is fluent and natural in the target language, even if this requires adjusting sentence structure or word choice. Avoid awkward phrasing that might result from a literal translation.
Tone and style consistency: Maintain the same tone and style as the original text. If the original is formal, ensure the translation remains formal; if it is casual, use casual language in the target language. For example, if the original uses colloquial language and slang, reflect that in the translation appropriately.''';

  Future<String> translateText(String context) async {
    OpenAI.requestsTimeOut = const Duration(minutes: 10);

    // Assistant에게 대화의 방향성을 알려주는 메시지
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
            '$defaultPrompt $prompt'),
      ],
      role: OpenAIChatMessageRole.system,
    );

    // 사용자가 보내는 메시지
    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          'Translate the following text to $targetLang: $context',
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

  // 대화형식으로 처리되므로 userMessageList를 전달해도 가장 마지막 message에 대해서만 처리함.
  Future<String> translateTextList(List<String> contextList) async {
    OpenAI.requestsTimeOut = const Duration(minutes: 10);

    // Assistant에게 대화의 방향성을 알려주는 메시지
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
      ],
      role: OpenAIChatMessageRole.system,
    );

    // 사용자가 보내는 메시지
    final context = contextList.map((context) => context).join("\r\n");
    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          'Translate the following text to $targetLang: $context',
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
    final config = ref.watch(configProvider);
    final options = config.value!;

    return TranslationService(
      targetLang: options['TRANSLATION_LANGUAGE'] ?? 'ko',
      model: options['OPENAI_API_MODEL'] ?? '',
      apiKey: options['OPENAI_API_KEY'] ?? '',
      prompt: options['TRANSLATION_PROMPT'] ?? '',
    );
  },
);
