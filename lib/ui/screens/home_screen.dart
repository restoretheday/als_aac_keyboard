import 'dart:async';
import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../domain/services/predictive_service.dart';
import '../../domain/services/tts_service.dart';
import '../../domain/services/keyboard_navigator.dart';
import '../../domain/services/precanned_navigator.dart';
import '../../domain/services/precanned_navigator.dart' as precanned;
import '../../data/file_message_repository.dart';
import '../widgets/binary_keyboard.dart';
import '../widgets/precanned_grid.dart';
import '../widgets/predictive_bar.dart';

enum ViewMode { precanned, keyboard, savedMessages }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AppState appState;
  ViewMode _viewMode = ViewMode.precanned;
  bool _isCoolingDown = false;
  Timer? _cooldownTimer;
  int _savedMessagesPage = 0;
  static const int _messagesPerPage = 8;

  @override
  void initState() {
    super.initState();
    appState = AppState(
      predictiveService: InMemoryFrenchPredictiveService(),
      ttsService: PlatformTtsService(),
      keyboardNavigator: KeyboardNavigator(),
      precannedNavigator: PrecannedNavigator(),
      messageRepository: FileMessageRepository(),
    );
    appState.initialize();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    appState.dispose();
    super.dispose();
  }

  Future<void> _runWithCooldown(Future<void> Function() action) async {
    if (_isCoolingDown) return;
    setState(() => _isCoolingDown = true);
    try {
      await action();
    } finally {
      _cooldownTimer?.cancel();
      _cooldownTimer = Timer(const Duration(milliseconds: 1000), () {
        if (mounted) setState(() => _isCoolingDown = false);
      });
    }
  }

  void _handlePrecannedSelection(int index) {
    appState.advancePrecannedSelection(index);
    // Check result synchronously since we store it in appState
    final result = appState.lastPrecannedResult;
    if (result != null) {
      if (result.type == precanned.PrecannedResultType.showKeyboard) {
        setState(() {
          _viewMode = ViewMode.keyboard;
          // Keep previous content when going to keyboard
        });
      } else if (result.type == precanned.PrecannedResultType.showSavedMessages) {
        setState(() {
          _viewMode = ViewMode.savedMessages;
          _savedMessagesPage = 0;
        });
      } else if (result.type == precanned.PrecannedResultType.sentence) {
        setState(() {
          _viewMode = ViewMode.keyboard;
          // Clear previous content and set new sentence
          appState.setCurrentText(result.text);
        });
      }
      appState.clearPrecannedResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          if (_viewMode == ViewMode.precanned) {
            return _buildPrecannedView(isLandscape, scheme);
          } else if (_viewMode == ViewMode.savedMessages) {
            return _buildSavedMessagesView(isLandscape, scheme);
          } else {
            return _buildKeyboardView(isLandscape, scheme);
          }
        },
      ),
    );
  }

  Widget _buildPrecannedView(bool isLandscape, ColorScheme scheme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: isLandscape
            ? Row(
                children: [
                  Expanded(
                    child: PrecannedGrid(
                      labels: appState.currentPrecannedChoices,
                      onSelect: _handlePrecannedSelection,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isCoolingDown ? null : () => _runWithCooldown(() async {
                      appState.stepBackInPrecannedSelection();
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.error,
                      foregroundColor: scheme.onError,
                      minimumSize: const Size(0, double.infinity),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.arrow_back, size: 28),
                    label: const Text('Retour', style: TextStyle(fontSize: 26)),
                  ),
                ],
              )
            : Column(
                children: [
                  Expanded(
                    child: PrecannedGrid(
                      labels: appState.currentPrecannedChoices,
                      onSelect: _handlePrecannedSelection,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _isCoolingDown ? null : () => _runWithCooldown(() async {
                      appState.stepBackInPrecannedSelection();
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.error,
                      foregroundColor: scheme.onError,
                      minimumSize: Size(double.infinity, 100),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.arrow_back, size: 28),
                    label: const Text('Retour', style: TextStyle(fontSize: 26)),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSavedMessagesView(bool isLandscape, ColorScheme scheme) {
    final messages = appState.savedMessages;
    final start = _savedMessagesPage * _messagesPerPage;
    final end = (start + _messagesPerPage).clamp(0, messages.length);
    final pageMessages = messages.sublist(start, end);
    final hasMore = end < messages.length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Phrases sauvées',
                    style: TextStyle(fontSize: isLandscape ? 48 : 40, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isCoolingDown ? null : () => _runWithCooldown(() async {
                    setState(() {
                      _viewMode = ViewMode.precanned;
                      _savedMessagesPage = 0;
                    });
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                    minimumSize: Size(isLandscape ? 200 : 160, isLandscape ? 100 : 80),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  icon: const Icon(Icons.arrow_back, size: 24),
                  label: const Text('Retour', style: TextStyle(fontSize: 22)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Column(
                children: [
                  for (final msg in pageMessages)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isCoolingDown ? null : () => _runWithCooldown(() async {
                                setState(() {
                                  _viewMode = ViewMode.keyboard;
                                  appState.setCurrentText(msg.text);
                                });
                              }),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: scheme.secondary,
                                foregroundColor: scheme.onSecondary,
                                minimumSize: Size(double.infinity, isLandscape ? 100 : 80),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(
                                msg.text,
                                style: TextStyle(fontSize: isLandscape ? 32 : 28),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: _isCoolingDown ? null : () => _runWithCooldown(() async {
                              await appState.deleteMessage(msg);
                            }),
                            icon: Icon(Icons.delete_outline, size: isLandscape ? 36 : 32, color: scheme.error),
                            style: IconButton.styleFrom(
                              minimumSize: Size(isLandscape ? 80 : 70, isLandscape ? 100 : 80),
                              backgroundColor: scheme.errorContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (pageMessages.length < _messagesPerPage)
                    const Spacer(),
                ],
              ),
            ),
            if (hasMore)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ElevatedButton(
                  onPressed: _isCoolingDown ? null : () => setState(() => _savedMessagesPage++),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    minimumSize: Size(double.infinity, isLandscape ? 100 : 80),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  ),
                  child: const Text('Suivant', style: TextStyle(fontSize: 26)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboardView(bool isLandscape, ColorScheme scheme) {
    final predictiveBar = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.primary.withOpacity(0.15), width: 1),
      ),
      child: PredictiveBar(
        predictions: appState.predictions,
        onAccept: appState.acceptPrediction,
      ),
    );

    if (isLandscape) {
      return Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _TextDisplay(text: appState.currentText, isLandscape: isLandscape),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isCoolingDown ? null : () => _runWithCooldown(() async {
                      setState(() => _viewMode = ViewMode.precanned);
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.tertiaryContainer,
                      foregroundColor: scheme.onTertiaryContainer,
                      minimumSize: Size(isLandscape ? 200 : 160, isLandscape ? 100 : 80),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    icon: const Icon(Icons.home, size: 24),
                    label: const Text('Accueil', style: TextStyle(fontSize: 22)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _KeyboardControls(
                                  isLandscape: isLandscape,
                                  isCoolingDown: _isCoolingDown,
                                  onBack: () => _runWithCooldown(() async {
                                    appState.stepBackInBinarySelection();
                                  }),
                                  onSpace: () => _runWithCooldown(() async {
                                    appState.addSpace();
                                  }),
                                  onRepeat: () => _runWithCooldown(() async {
                                    appState.repeatLastCharacter();
                                  }),
                                  lastChar: appState.lastCharacter,
                                ),
                                const SizedBox(height: 12),
                                _ActionButtons(
                                  isLandscape: isLandscape,
                                  isCoolingDown: _isCoolingDown,
                                  onBackspace: () => _runWithCooldown(() async {
                                    appState.backspace();
                                  }),
                                  onClear: () => _runWithCooldown(() async {
                                    appState.clear();
                                  }),
                                  onSave: () => _runWithCooldown(() async {
                                    await appState.saveCurrentMessage();
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Message enregistré')),
                                      );
                                    }
                                  }),
                                  onSpeak: () async {
                                    // Fire and forget TTS to avoid blocking
                                    appState.speak();
                                    await _runWithCooldown(() async {});
                                  },
                                  onShowMessages: () => _runWithCooldown(() async {
                                    setState(() {
                                      _viewMode = ViewMode.precanned;
                                    });
                                  }),
                                ),
                                const SizedBox(height: 12),
                                predictiveBar,
                              ],
                            ),
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _TextDisplay(text: appState.currentText, isLandscape: isLandscape),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isCoolingDown ? null : () => _runWithCooldown(() async {
                      setState(() => _viewMode = ViewMode.precanned);
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.tertiaryContainer,
                      foregroundColor: scheme.onTertiaryContainer,
                      minimumSize: const Size(120, 80),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    icon: const Icon(Icons.home, size: 20),
                    label: const Text('Accueil', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: SafeArea(
              top: false,
              child: BinaryKeyboard(
                labels: appState.currentBinaryChoices,
                onSelect: appState.advanceBinarySelection,
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _KeyboardControls(
                    isLandscape: isLandscape,
                    isCoolingDown: _isCoolingDown,
                    onBack: () => _runWithCooldown(() async {
                      appState.stepBackInBinarySelection();
                    }),
                    onSpace: () => _runWithCooldown(() async {
                      appState.addSpace();
                    }),
                    onRepeat: () => _runWithCooldown(() async {
                      appState.repeatLastCharacter();
                    }),
                    lastChar: appState.lastCharacter,
                  ),
                  const SizedBox(height: 12),
                  _ActionButtons(
                    isLandscape: isLandscape,
                    isCoolingDown: _isCoolingDown,
                    onBackspace: () => _runWithCooldown(() async {
                      appState.backspace();
                    }),
                    onClear: () => _runWithCooldown(() async {
                      appState.clear();
                    }),
                    onSave: () => _runWithCooldown(() async {
                      await appState.saveCurrentMessage();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Message enregistré')),
                        );
                      }
                    }),
                    onSpeak: () async {
                      // Fire and forget TTS to avoid blocking
                      appState.speak();
                      await _runWithCooldown(() async {});
                    },
                    onShowMessages: () => _runWithCooldown(() async {
                      setState(() {
                        _viewMode = ViewMode.precanned;
                      });
                    }),
                  ),
                  const SizedBox(height: 12),
                  predictiveBar,
                ],
              ),
            ),
          ),
        ],
      );
    }
  }
}

class _TextDisplay extends StatelessWidget {
  const _TextDisplay({required this.text, required this.isLandscape});

  final String text;
  final bool isLandscape;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fontSize = isLandscape ? 64.0 : 56.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isLandscape ? 20 : 16, vertical: isLandscape ? 18 : 14),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.primary.withOpacity(0.2), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: BoxConstraints(minHeight: fontSize * 1.2),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Text(
          text.toLowerCase(),
          maxLines: 1,
          softWrap: false,
          style: TextStyle(
            fontSize: fontSize,
            color: scheme.onSurface,
            fontWeight: FontWeight.w500,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.isLandscape,
    required this.isCoolingDown,
    required this.onBackspace,
    required this.onClear,
    required this.onSave,
    required this.onSpeak,
    required this.onShowMessages,
  });

  final bool isLandscape;
  final bool isCoolingDown;
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
          minimumSize: Size(isLandscape ? 200 : 170, isLandscape ? 140 : 120),
          padding: EdgeInsets.symmetric(
            horizontal: isLandscape ? 28 : 24,
            vertical: isLandscape ? 26 : 22,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        );

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: isCoolingDown ? null : onBackspace,
          style: filled(scheme.tertiary, scheme.onTertiary),
          icon: Icon(Icons.backspace_outlined, size: isLandscape ? 32 : 28),
          label: Text('Effacer', style: TextStyle(fontSize: isLandscape ? 24 : 22)),
        ),
        ElevatedButton.icon(
          onPressed: isCoolingDown ? null : onClear,
          style: filled(scheme.error, scheme.onError),
          icon: Icon(Icons.clear, size: isLandscape ? 32 : 28),
          label: Text('Vider', style: TextStyle(fontSize: isLandscape ? 24 : 22)),
        ),
        ElevatedButton.icon(
          onPressed: isCoolingDown ? null : onSpeak,
          style: filled(scheme.primary, scheme.onPrimary),
          icon: Icon(Icons.volume_up_outlined, size: isLandscape ? 32 : 28),
          label: Text('Parler', style: TextStyle(fontSize: isLandscape ? 24 : 22)),
        ),
        ElevatedButton.icon(
          onPressed: isCoolingDown ? null : onSave,
          style: filled(scheme.secondary, scheme.onSecondary),
          icon: Icon(Icons.save_outlined, size: isLandscape ? 32 : 28),
          label: Text('Enregistrer', style: TextStyle(fontSize: isLandscape ? 24 : 22)),
        ),
        ElevatedButton.icon(
          onPressed: isCoolingDown ? null : onShowMessages,
          style: filled(scheme.tertiaryContainer, scheme.onTertiaryContainer),
          icon: Icon(Icons.history, size: isLandscape ? 32 : 28),
          label: Text('Messages', style: TextStyle(fontSize: isLandscape ? 24 : 22)),
        ),
      ],
    );
  }
}

class _KeyboardControls extends StatelessWidget {
  const _KeyboardControls({
    required this.isLandscape,
    required this.isCoolingDown,
    required this.onBack,
    required this.onSpace,
    required this.onRepeat,
    required this.lastChar,
  });

  final bool isLandscape;
  final bool isCoolingDown;
  final VoidCallback onBack;
  final VoidCallback onSpace;
  final VoidCallback onRepeat;
  final String lastChar;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canRepeat = lastChar.isNotEmpty;
    final buttonHeight = isLandscape ? 150.0 : 120.0;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isCoolingDown ? null : onBack,
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
              minimumSize: Size(0, buttonHeight),
              padding: EdgeInsets.symmetric(horizontal: isLandscape ? 26 : 22, vertical: isLandscape ? 22 : 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            icon: const Icon(Icons.arrow_back, size: 24),
            label: const Text('Retour', style: TextStyle(fontSize: 24)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isCoolingDown ? null : onSpace,
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.tertiary,
              foregroundColor: scheme.onTertiary,
              minimumSize: Size(0, buttonHeight),
              padding: EdgeInsets.symmetric(horizontal: isLandscape ? 26 : 22, vertical: isLandscape ? 22 : 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            icon: const Icon(Icons.space_bar, size: 24),
            label: const Text('Espace', style: TextStyle(fontSize: 24)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: (!isCoolingDown && canRepeat) ? onRepeat : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              minimumSize: Size(0, buttonHeight),
              padding: EdgeInsets.symmetric(horizontal: isLandscape ? 26 : 22, vertical: isLandscape ? 22 : 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text(
              canRepeat ? lastChar : '',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
