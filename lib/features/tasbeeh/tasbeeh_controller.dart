import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/hive_boxes.dart';

/// Standard, widely-known tasbeeh phrases (not a sourced Hadith/Dua text —
/// just the common transliterations used in every tasbeeh counter).
const List<String> tasbeehDhikrPresets = [
  'SubhanAllah',
  'Alhamdulillah',
  'Allahu Akbar',
  'La ilaha illallah',
  'Astaghfirullah',
  'La hawla wala quwwata illa billah',
];

const List<int> tasbeehGoalPresets = [33, 34, 50, 100, 300, 500, 1000];

const _defaultDhikr = 'SubhanAllah';
const _defaultGoal = 33;

class TasbeehState {
  const TasbeehState({
    required this.count,
    required this.goal,
    required this.dhikr,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.isPaused,
  });

  final int count;
  final int goal;
  final String dhikr;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool isPaused;

  double get progress => goal <= 0 ? 0 : (count / goal).clamp(0, 1);
  bool get goalReached => count >= goal;

  TasbeehState copyWith({
    int? count,
    int? goal,
    String? dhikr,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? isPaused,
  }) {
    return TasbeehState(
      count: count ?? this.count,
      goal: goal ?? this.goal,
      dhikr: dhikr ?? this.dhikr,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}

/// Manages the Tasbeeh count and its settings, auto-saving every change to
/// the `tasbeeh` Hive box so progress survives closing and reopening the app.
class TasbeehNotifier extends Notifier<TasbeehState> {
  Box get _box => Hive.box(HiveBoxes.tasbeeh);

  @override
  TasbeehState build() {
    final box = _box;
    return TasbeehState(
      count: box.get('count', defaultValue: 0) as int,
      goal: box.get('goal', defaultValue: _defaultGoal) as int,
      dhikr: box.get('dhikr', defaultValue: _defaultDhikr) as String,
      soundEnabled: box.get('soundEnabled', defaultValue: true) as bool,
      vibrationEnabled:
          box.get('vibrationEnabled', defaultValue: true) as bool,
      isPaused: box.get('isPaused', defaultValue: false) as bool,
    );
  }

  void increment() {
    if (state.isPaused) return;

    state = state.copyWith(count: state.count + 1);
    _box.put('count', state.count);

    if (state.soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
    if (state.vibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  void reset() {
    state = state.copyWith(count: 0);
    _box.put('count', 0);
  }

  void togglePause() {
    state = state.copyWith(isPaused: !state.isPaused);
    _box.put('isPaused', state.isPaused);
  }

  void setGoal(int goal) {
    if (goal <= 0) return;
    state = state.copyWith(goal: goal);
    _box.put('goal', goal);
  }

  void setDhikr(String dhikr) {
    if (dhikr.trim().isEmpty) return;
    state = state.copyWith(dhikr: dhikr.trim());
    _box.put('dhikr', state.dhikr);
  }

  void setSoundEnabled(bool enabled) {
    state = state.copyWith(soundEnabled: enabled);
    _box.put('soundEnabled', enabled);
  }

  void setVibrationEnabled(bool enabled) {
    state = state.copyWith(vibrationEnabled: enabled);
    _box.put('vibrationEnabled', enabled);
  }
}

final tasbeehProvider = NotifierProvider<TasbeehNotifier, TasbeehState>(
  TasbeehNotifier.new,
);
