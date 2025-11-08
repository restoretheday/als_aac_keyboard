import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../domain/services/predictive_service.dart';
import '../../domain/services/tts_service.dart';
import '../../domain/services/keyboard_navigator.dart';
import '../../data/file_message_repository.dart';
import '../widgets/binary_keyboard.dart';
import '../widgets/predictive_bar.dart';
import '../widgets/message_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AppState appState;
  bool _showMessagesPanel = false;

  @override
  void initState() {
    super.initState();
    appState = AppState(
      predictiveService: InMemoryFrenchPredictiveService(),
      ttsService: IosTtsService(),
      keyboardNavigator: KeyboardNavigator(),
      messageRepository: FileMessageRepository(),
    );
    appState.initialize();
  }

  @override
  void dispose() {
    appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.background,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: appState,
            builder: (context, _) {
              return Column(
                children: [
                  Flexible(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _MessageComposer(
                            text: appState.currentText,
                            onBackspace: appState.backspace,
                            onClear: appState.clear,
                            onSave: () async {
                              await appState.saveCurrentMessage();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Message enregistré')),
                                );
                              }
                            },
                            onSpeak: appState.speak,
                            onShowMessages: () => setState(() => _showMessagesPanel = !_showMessagesPanel),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: scheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: scheme.primary.withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                            child: PredictiveBar(
                              predictions: appState.predictions,
                              onAccept: appState.acceptPrediction,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: SafeArea(
                      top: false,
                      child: BinaryKeyboard(
                        labels: appState.currentBinaryChoices,
                        onSelect: appState.advanceBinarySelection,
                        onBack: appState.stepBackInBinarySelection,
                        onRepeatLast: appState.repeatLastCharacter,
                        lastChar: appState.lastCharacter,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          // Messages panel overlay
          if (_showMessagesPanel)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: SafeArea(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      constraints: const BoxConstraints(maxHeight: 600),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Messages enregistrés',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              IconButton(
                                onPressed: () => setState(() => _showMessagesPanel = false),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 400,
                            child: MessageList(
                              messages: appState.savedMessages,
                              onTapWord: (word) {
                                appState.addDictionaryWordToMessage(word);
                                setState(() => _showMessagesPanel = false);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({
    required this.text,
    required this.onBackspace,
    required this.onClear,
    required this.onSave,
    required this.onSpeak,
    required this.onShowMessages,
  });

  final String text;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final Future<void> Function() onSave;
  final Future<void> Function() onSpeak;
  final VoidCallback onShowMessages;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    ButtonStyle filled(Color bg, Color fg) => ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          minimumSize: const Size(120, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border.all(color: scheme.primary.withOpacity(0.2), width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 28,
              color: scheme.onSurface,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: onBackspace,
              style: filled(scheme.tertiary, scheme.onTertiary),
              icon: const Icon(Icons.backspace_outlined),
              label: const Text('Effacer'),
            ),
            ElevatedButton.icon(
              onPressed: onClear,
              style: filled(scheme.error, scheme.onError),
              icon: const Icon(Icons.clear),
              label: const Text('Vider'),
            ),
            ElevatedButton.icon(
              onPressed: onSpeak,
              style: filled(scheme.primary, scheme.onPrimary),
              icon: const Icon(Icons.volume_up_outlined),
              label: const Text('Parler'),
            ),
            ElevatedButton.icon(
              onPressed: onSave,
              style: filled(scheme.secondary, scheme.onSecondary),
              icon: const Icon(Icons.save_outlined),
              label: const Text('Enregistrer'),
            ),
            ElevatedButton.icon(
              onPressed: onShowMessages,
              style: filled(scheme.tertiaryContainer, scheme.onTertiaryContainer),
              icon: const Icon(Icons.history),
              label: const Text('Messages'),
            ),
          ],
        ),
      ],
    );
  }
}
