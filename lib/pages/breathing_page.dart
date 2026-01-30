import 'package:belfort/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class BreathingPage extends StatefulWidget {
  const BreathingPage({super.key});

  @override
  State<BreathingPage> createState() => _BreathingPageState();
}

class _BreathingPageState extends State<BreathingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;

  late FlutterTts _flutterTts;
  bool _isVoiceEnabled = true;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _initTts();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _sizeAnimation = Tween<double>(begin: 150.0, end: 300.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        _speak("Inhale");
      } else if (status == AnimationStatus.reverse) {
        _speak("Exhale");
      }
    });

    _startExercise();
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();

    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setPitch(1.0);

    _speak("Inhale");
  }

  void _startExercise() {
    _controller.repeat(reverse: true);
    setState(() => _isPaused = false);
  }

  void _togglePause() {
    setState(() {
      if (_isPaused) {
        _controller.repeat(reverse: true);
        _isPaused = false;
      } else {
        _controller.stop();
        _flutterTts.stop();
        _isPaused = true;
      }
    });
  }

  Future<void> _speak(String text) async {
    if (!_isVoiceEnabled || _isPaused) return;
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _controller.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.greenDark, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final bool isInhaling =
                      _controller.status == AnimationStatus.forward;

                  final instruction = isInhaling ? "Inhale..." : "Exhale...";

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: _sizeAnimation.value + 40,
                        height: _sizeAnimation.value + 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.greenPrimary.withValues(alpha: 0.1),
                        ),
                      ),
                      Container(
                        width: _sizeAnimation.value,
                        height: _sizeAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.softTint,
                              AppColors.greenPrimary.withValues(alpha: 0.4),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.greenPrimary.withValues(
                                alpha: 0.2,
                              ),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            instruction,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: AppColors.greenDark,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.only(bottom: 50),
            child: Column(
              children: [
                const Text(
                  "Focus on your breath",
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      onPressed: () {
                        setState(() {
                          _isVoiceEnabled = !_isVoiceEnabled;
                          if (!_isVoiceEnabled) _flutterTts.stop();
                        });
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.softTint,
                        foregroundColor: AppColors.greenDark,
                      ),
                      icon: Icon(
                        _isVoiceEnabled ? Icons.volume_up : Icons.volume_off,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 24),

                    IconButton.filled(
                      onPressed: _togglePause,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.greenDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                      icon: Icon(
                        _isPaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        size: 42,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
