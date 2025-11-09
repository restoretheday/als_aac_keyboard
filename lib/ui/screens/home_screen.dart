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
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    
    return Scaffold(
      backgroundColor: scheme.background,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: appState,
            builder: (context, _) {
              if (isLandscape) {
                // Landscape: side-by-side layout
                return Row(
                  children: [
                    Flexible(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: _MessageComposer(
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
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                        left: false,
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
              } else {
                // Portrait: stacked layout
                return Column(
                  children: [
                    Flexible(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: _MessageComposer(
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
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
              }
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
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    
    ButtonStyle filled(Color bg, Color fg) => ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          minimumSize: Size(isLandscape ? 140 : 120, isLandscape ? 64 : 56),
          padding: EdgeInsets.symmetric(
            horizontal: isLandscape ? 20 : 16,
            vertical: isLandscape ? 16 : 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(isLandscape ? 24 : 20),
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border.all(color: scheme.primary.withOpacity(0.2), width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: isLandscape ? 32 : 28,
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: onBackspace,
              style: filled(scheme.tertiary, scheme.onTertiary),
              icon: Icon(Icons.backspace_outlined, size: isLandscape ? 28 : 24),
              label: Text('Effacer', style: TextStyle(fontSize: isLandscape ? 18 : 16)),
            ),
            ElevatedButton.icon(
              onPressed: onClear,
              style: filled(scheme.error, scheme.onError),
              icon: Icon(Icons.clear, size: isLandscape ? 28 : 24),
              label: Text('Vider', style: TextStyle(fontSize: isLandscape ? 18 : 16)),
            ),
            ElevatedButton.icon(
              onPressed: onSpeak,
              style: filled(scheme.primary, scheme.onPrimary),
              icon: Icon(Icons.volume_up_outlined, size: isLandscape ? 28 : 24),
              label: Text('Parler', style: TextStyle(fontSize: isLandscape ? 18 : 16)),
            ),
            ElevatedButton.icon(
              onPressed: onSave,
              style: filled(scheme.secondary, scheme.onSecondary),
              icon: Icon(Icons.save_outlined, size: isLandscape ? 28 : 24),
              label: Text('Enregistrer', style: TextStyle(fontSize: isLandscape ? 18 : 16)),
            ),
            ElevatedButton.icon(
              onPressed: onShowMessages,
              style: filled(scheme.tertiaryContainer, scheme.onTertiaryContainer),
              icon: Icon(Icons.history, size: isLandscape ? 28 : 24),
              label: Text('Messages', style: TextStyle(fontSize: isLandscape ? 18 : 16)),
            ),
          ],
        ),
      ],
    );
  }
}
