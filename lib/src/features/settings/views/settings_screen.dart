import 'package:epub_translator/src/db/provider/database_provider.dart'; // DatabaseHelper, ConfigNotifier와 관련된 파일
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  // Form의 상태를 관리하는 GlobalKey
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // 저장된 설정 값을 불러와 TextField에 세팅
    _loadSettings();
  }

  void _loadSettings() async {
    // OpenAI API MODEL 및 API KEY 불러오기
    await ref.read(configProvider.notifier).loadAllConfigs();

    final config = ref.read(configProvider);
    final model = config['OPENAI_API_MODEL'];
    final apiKey = config['OPENAI_API_KEY'];
    final prompt = config['TRANSLATION_PROMPT'];

    setState(() {
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
      final model = _modelController.text;
      final apiKey = _apiKeyController.text;
      final prompt = _promptController.text;

      if (model.isNotEmpty && apiKey.isNotEmpty) {
        configNotifier.saveConfig('OPENAI_API_MODEL', model);
        configNotifier.saveConfig('OPENAI_API_KEY', apiKey);
        configNotifier.saveConfig('TRANSLATION_PROMPT', prompt);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('설정이 저장되었습니다.')),
        );
        ref.watch(configProvider.notifier).loadAllConfigs();
      }
    } else {
      // 유효하지 않은 입력이 있을 경우
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필드를 올바르게 입력하세요.')),
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
        title: const Text('설정 관리'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Form의 상태를 관리하는 키
            child: Column(
              children: [
                TextFormField(
                  controller: _modelController,
                  decoration:
                      const InputDecoration(labelText: 'OPENAI API MODEL'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '모델을 입력하세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _apiKeyController,
                  decoration:
                      const InputDecoration(labelText: 'OPENAI API KEY'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'API 키를 입력하세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  minLines: 10,
                  maxLines: 40,
                  controller: _promptController,
                  decoration:
                      const InputDecoration(labelText: 'TRANSLATION PROMPT'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '번역 프롬프트를 입력하세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveSettings,
                  child: const Text('설정 저장'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
