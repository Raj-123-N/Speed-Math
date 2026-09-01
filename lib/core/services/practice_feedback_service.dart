import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized audio + haptic feedback for Practice.
class PracticeFeedbackService {
  PracticeFeedbackService._();

  static final PracticeFeedbackService instance = PracticeFeedbackService._();

  final AudioPlayer _player = AudioPlayer();
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _animationsEnabled = true;
  bool _loaded = false;

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

  Future<void> correct() => _play('music/bonus.aac', haptic: HapticFeedback.lightImpact);
  Future<void> incorrect() => _play('music/lose.aac', haptic: HapticFeedback.heavyImpact);
  Future<void> start() => _play('music/start.aac', haptic: HapticFeedback.mediumImpact);

  Future<void> complete(bool successful) => _play(
        successful ? 'music/won.aac' : 'music/end.aac',
        haptic: HapticFeedback.mediumImpact,
      );

  Future<void> tap() async {
    if (!_loaded) await initialize();
    if (_vibrationEnabled) await HapticFeedback.selectionClick();
  }

  Future<void> previewSound() => _play('music/start.aac');

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
