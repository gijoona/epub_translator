import 'package:dart_openai/dart_openai.dart';
import 'package:epub_translator/src/features/common/configs/env_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TranslationService {
  final String apiKey;
  final int maxTokens = 500;

  TranslationService({required this.apiKey}) {
    OpenAI.apiKey = apiKey;
  }

  Future<String> translateText(String context, String targetLanguage) async {
    OpenAI.requestsTimeOut = const Duration(minutes: 10);

    // Assistant에게 대화의 방향성을 알려주는 메시지
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text("""
            You are an expert in translating EPUB files, specializing in preserving EPUB and HTML tags. Your task is to translate text while maintaining the structure of the original EPUB document, including all HTML and ruby tags. 
            - Keep all HTML and EPUB-specific tags intact, including paragraphs and page breaks.
            - Translate the content accurately while maintaining the original meaning and context.
            - If the original text contains ruby tags for furigana (e.g., Japanese), preserve both the ruby tags and the furigana text. Ensure the correct placement of furigana above the appropriate kanji characters.
            - Maintain the tone and style of the original document, whether it is formal, informal, technical, or literary.
            - Translate the text accurately, preserving the narrative style and emotional impact of the original text.
            - For personal names and proper nouns, do not translate them. Instead, retain them in their original pronunciation using romaji (for Japanese translations). For example, "John" should remain as "John" in the translated text, rather than being converted to "ジョン". Similarly, culturally specific titles and names should retain their original form and pronunciation.
          """),
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
      maxTokens: maxTokens,
    );

    String message =
        chatCompletion.choices.first.message.content![0].text.toString();
    return message;
  }
}

final translationServiceProvider = Provider(
  (ref) => TranslationService(apiKey: ref.watch(envConfigProvider)),
);
