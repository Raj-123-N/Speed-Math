import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized audio + haptic feedback for Practice.
class PracticeFeedbackService {
  PracticeFeedbackService._() {
    _player.audioCache.prefix = '';
  }

  static final PracticeFeedbackService instance = PracticeFeedbackService._();

  final AudioPlayer _player = AudioPlayer();
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _animationsEnabled = true;
  bool _loaded = false;

  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get animationsEnabled => _animationsEnabled;

  Future<void> initialize() async {
    if (_loaded) return;
    await refresh();
  }

  Future<void> refresh() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('settings_sound') ?? true;
    _vibrationEnabled = prefs.getBool('settings_vibration') ?? true;
    _animationsEnabled = prefs.getBool('settings_practice_animations') ?? true;
    _loaded = true;
  }

  /// Plays start sound when drill begins
  Future<void> start() =>
      _play('asset/music/start.aac', haptic: HapticFeedback.mediumImpact);

  /// Plays bonus sound on correct answer
  Future<void> playCorrect() =>
      _play('asset/music/bonus.aac', haptic: HapticFeedback.lightImpact);

  /// Triggers haptic vibration on wrong answer (suppressing audio unless desired)
  Future<void> playWrong() async {
    if (!_loaded) await initialize();
    if (_vibrationEnabled) await HapticFeedback.heavyImpact();
  }

  /// Plays won sound on high score (>= 80%)
  Future<void> playWon() =>
      _play('asset/music/won.aac', haptic: HapticFeedback.mediumImpact);

  /// Plays lose sound on low score (< 50%)
  Future<void> playLose() =>
      _play('asset/music/lose.aac', haptic: HapticFeedback.heavyImpact);

  /// Plays normal end sound
  Future<void> end() =>
      _play('asset/music/end.aac', haptic: HapticFeedback.mediumImpact);

  // Backward compatibility aliases
  Future<void> correct() => playCorrect();
  Future<void> incorrect() => playWrong();
  Future<void> complete(bool successful) => successful ? playWon() : end();

  Future<void> tap() async {
    if (!_loaded) await initialize();
    if (_vibrationEnabled) await HapticFeedback.selectionClick();
  }

  Future<void> previewSound() => _play('asset/music/start.aac');

  Future<void> _play(String asset, {Future<void> Function()? haptic}) async {
    if (!_loaded) await initialize();
    if (_vibrationEnabled && haptic != null) await haptic();
    if (!_soundEnabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(asset));
    } catch (_) {
      // Feedback must never interrupt a Practice session if audio fails.
    }
  }

  Future<void> dispose() async => _player.dispose();
}
