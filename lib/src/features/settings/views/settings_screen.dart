import 'package:epub_translator/generated/l10n.dart';
import 'package:epub_translator/src/db/providers/config_provider.dart'; // DatabaseHelper, ConfigNotifier와 관련된 파일
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum ThemeMode { system, light, dark }

class SettingsScreen extends ConsumerStatefulWidget {
  static const String routeURL = '/settings';
  static const String routeName = 'settings';

  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // 각각의 설정 필드에 사용할 TextEditingController
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();
  var _themeMode = ThemeMode.system;
  var _targetLanguage = 'ko';
  final List<bool> _isOpen = [true, true, false];

  // Form의 상태를 관리하는 GlobalKey
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // 저장된 설정 값을 불러와 TextField에 세팅
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // OpenAI API MODEL 및 API KEY 불러오기
    final config = ref.read(configProvider).value!;
    final theme = config['APP_THEMEMODE'] ?? '0';
    final language = config['TRANSLATION_LANGUAGE'] ?? 'ko';
    final model = config['OPENAI_API_MODEL'];
    final apiKey = config['OPENAI_API_KEY'];
    final prompt = config['TRANSLATION_PROMPT'];

    setState(() {
      _themeMode = ThemeMode.values.elementAt(int.parse(theme));
      _targetLanguage = language;
      _modelController.text = model ?? '';
      _apiKeyController.text = apiKey ?? '';
      _promptController.text = prompt ?? '';
    });
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      // 폼이 유효할 경우에만 설정 저장
      final configNotifier = ref.read(configProvider.notifier);

      // 각 입력 필드에서 설정 값을 가져와 저장
      final theme = _themeMode.index.toString();
      final language = _targetLanguage;
      final model = _modelController.text;
      final apiKey = _apiKeyController.text;
      final prompt = _promptController.text;

      configNotifier.saveConfig('APP_THEMEMODE', theme);
      configNotifier.saveConfig('TRANSLATION_LANGUAGE', language);
      configNotifier.saveConfig('OPENAI_API_MODEL', model);
      configNotifier.saveConfig('OPENAI_API_KEY', apiKey);
      configNotifier.saveConfig('TRANSLATION_PROMPT', prompt);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).successMsg('saveSattings'),
          ),
        ),
      );
      ref.read(configProvider.notifier).loadAllConfigs();
    } else {
      // 유효하지 않은 입력이 있을 경우
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).validMsg('notInvalid'),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _modelController.dispose();
    _apiKeyController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settingsTitle),
        actions: [
          IconButton(
            tooltip: S.of(context).settingsSaveBtn,
            onPressed: _saveSettings,
            icon: const FaIcon(FontAwesomeIcons.check),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ExpansionPanelList(
            elevation: 0,
            children: [
              ExpansionPanel(
                headerBuilder: (context, isExpanded) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(S.of(context).themeMode),
                ),
                body: SegmentedButton(
                  segments: [
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      label: Text(S.of(context).themeModeOption('system')),
                      icon: const FaIcon(FontAwesomeIcons.circleHalfStroke),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      label: Text(S.of(context).themeModeOption('light')),
                      icon: const FaIcon(FontAwesomeIcons.sun),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      label: Text(S.of(context).themeModeOption('dark')),
                      icon: const FaIcon(FontAwesomeIcons.moon),
                    ),
                  ],
                  selected: {_themeMode},
                  onSelectionChanged: (Set<ThemeMode> newSelection) {
                    setState(() {
                      // By default there is only a single segment that can be
                      // selected at one time, so its value is always the first
                      // item in the selected set.
                      _themeMode = newSelection.first;
                    });
                  },
                ),
                isExpanded: _isOpen[0],
              ),
              ExpansionPanel(
                headerBuilder: (context, isExpanded) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(S.of(context).translateLanguage),
                ),
                body: SegmentedButton(
                  segments: [
                    ButtonSegment<String>(
                      value: 'ko',
                      label: Text(S.of(context).translateLanguageOption('ko')),
                      icon: const FaIcon(FontAwesomeIcons.circle),
                    ),
                    ButtonSegment<String>(
                      value: 'ja',
                      label: Text(S.of(context).translateLanguageOption('ja')),
                      icon: const FaIcon(FontAwesomeIcons.circle),
                    ),
                    ButtonSegment<String>(
                      value: 'en',
                      label: Text(S.of(context).translateLanguageOption('en')),
                      icon: const FaIcon(FontAwesomeIcons.circle),
                    ),
                  ],
                  selected: {_targetLanguage},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      // By default there is only a single segment that can be
                      // selected at one time, so its value is always the first
                      // item in the selected set.
                      _targetLanguage = newSelection.first;
                    });
                  },
                ),
                isExpanded: _isOpen[1],
              ),
              ExpansionPanel(
                headerBuilder: (context, isExpanded) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(S.of(context).openaiAPI),
                ),
                body: Form(
                  key: _formKey, // Form의 상태를 관리하는 키
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _modelController,
                          decoration: InputDecoration(
                              labelText: S.of(context).openaiAPIModel),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _apiKeyController,
                          decoration: InputDecoration(
                              labelText: S.of(context).openaiAPIKey),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          minLines: 10,
                          maxLines: 40,
                          controller: _promptController,
                          decoration: InputDecoration(
                              labelText: S.of(context).openaiAPIPrompt),
                        ),
                      ],
                    ),
                  ),
                ),
                isExpanded: _isOpen[2],
              ),
            ],
            expansionCallback: (i, isOpen) =>
                setState(() => _isOpen[i] = isOpen),
          ),
        ),
      ),
    );
  }
}
