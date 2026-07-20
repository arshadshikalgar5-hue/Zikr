import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/dhikr_repository.dart';
import 'tasbeeh_controller.dart';

class TasbeehScreen extends ConsumerWidget {
  const TasbeehScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tasbeehProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Tasbeeh')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const _DhikrSelector(),
              const SizedBox(height: 20),
              Text(
                state.dhikr,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const _CounterRing(),
              const SizedBox(height: 24),
              const _GoalSelector(),
              const SizedBox(height: 24),
              const _ControlsRow(),
              const SizedBox(height: 16),
              const _SettingsCard(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Loads the preset options from the bundled dhikr library before handing
/// off to [_DhikrDropdown] — the dropdown needs the full preset list
/// available at construction time (see below), so it only mounts once the
/// library has loaded.
class _DhikrSelector extends ConsumerWidget {
  const _DhikrSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(dhikrLibraryProvider);

    return library.when(
      data: (entries) => _DhikrDropdown(
        presets: [for (final entry in entries) entry.transliteration],
      ),
      loading: () => const LinearProgressIndicator(),
      error: (error, stackTrace) =>
          const Text('Could not load dhikr options.'),
    );
  }
}

/// Preset/custom dhikr dropdown. Kept stateful only to hold the
/// [TextEditingController] for the custom-text field.
class _DhikrDropdown extends ConsumerStatefulWidget {
  const _DhikrDropdown({required this.presets});

  final List<String> presets;

  @override
  ConsumerState<_DhikrDropdown> createState() => _DhikrDropdownState();
}

class _DhikrDropdownState extends ConsumerState<_DhikrDropdown> {
  late final TextEditingController _customController;
  late bool _customMode;

  @override
  void initState() {
    super.initState();
    final dhikr = ref.read(tasbeehProvider).dhikr;
    _customMode = !widget.presets.contains(dhikr);
    _customController = TextEditingController(text: _customMode ? dhikr : '');
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tasbeehProvider);
    final notifier = ref.read(tasbeehProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _customMode ? 'Custom' : state.dhikr,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Dhikr',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final preset in widget.presets)
              DropdownMenuItem(
                value: preset,
                child: Text(preset, overflow: TextOverflow.ellipsis),
              ),
            const DropdownMenuItem(
              value: 'Custom',
              child: Text('Custom...', overflow: TextOverflow.ellipsis),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;
            if (value == 'Custom') {
              setState(() => _customMode = true);
              return;
            }
            setState(() => _customMode = false);
            notifier.setDhikr(value);
          },
        ),
        if (_customMode) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _customController,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Custom dhikr',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.check),
                tooltip: 'Save',
                onPressed: () => notifier.setDhikr(_customController.text),
              ),
            ),
            onSubmitted: notifier.setDhikr,
          ),
        ],
      ],
    );
  }
}

/// The large tap-to-count circle. This is deliberately the only tappable
/// area for incrementing (rather than the whole screen) so it can't
/// intercept taps meant for the dropdown, chips, or buttons around it.
class _CounterRing extends ConsumerWidget {
  const _CounterRing();

  static const _size = 260.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tasbeehProvider);
    final notifier = ref.read(tasbeehProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final ringColor = state.goalReached
        ? colorScheme.secondary
        : colorScheme.primary;

    return Center(
      child: GestureDetector(
        key: const Key('tasbeehCounterRing'),
        behavior: HitTestBehavior.opaque,
        onTap: notifier.increment,
        child: SizedBox(
          width: _size,
          height: _size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: state.progress,
                  strokeWidth: 14,
                  strokeCap: StrokeCap.round,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(ringColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${state.count}',
                    style: textTheme.headlineLarge?.copyWith(
                      fontSize: 56,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'of ${state.goal}',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (state.isPaused) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Paused',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalSelector extends ConsumerWidget {
  const _GoalSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tasbeehProvider);
    final notifier = ref.read(tasbeehProvider.notifier);
    final isCustomGoal = !tasbeehGoalPresets.contains(state.goal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Goal', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final goal in tasbeehGoalPresets)
              ChoiceChip(
                label: Text('$goal'),
                selected: !isCustomGoal && state.goal == goal,
                onSelected: (_) => notifier.setGoal(goal),
              ),
            ChoiceChip(
              label: Text(isCustomGoal ? 'Custom (${state.goal})' : 'Custom'),
              selected: isCustomGoal,
              onSelected: (_) =>
                  _pickCustomGoal(context, notifier, state.goal),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickCustomGoal(
    BuildContext context,
    TasbeehNotifier notifier,
    int currentGoal,
  ) async {
    final controller = TextEditingController(text: currentGoal.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom goal'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Target count'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, int.tryParse(controller.text)),
            child: const Text('Set'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null && result > 0) {
      notifier.setGoal(result);
    }
  }
}

class _ControlsRow extends ConsumerWidget {
  const _ControlsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tasbeehProvider);
    final notifier = ref.read(tasbeehProvider.notifier);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            onPressed: () => _confirmReset(context, notifier),
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            onPressed: notifier.togglePause,
            icon: Icon(state.isPaused ? Icons.play_arrow : Icons.pause),
            label: Text(state.isPaused ? 'Continue' : 'Pause'),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmReset(
    BuildContext context,
    TasbeehNotifier notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset count?'),
        content: const Text('This will set the counter back to 0.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      notifier.reset();
    }
  }
}

class _SettingsCard extends ConsumerWidget {
  const _SettingsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tasbeehProvider);
    final notifier = ref.read(tasbeehProvider.notifier);

    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.volume_up_outlined),
            title: const Text('Sound'),
            value: state.soundEnabled,
            onChanged: notifier.setSoundEnabled,
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: const Text('Vibration'),
            value: state.vibrationEnabled,
            onChanged: notifier.setVibrationEnabled,
          ),
        ],
      ),
    );
  }
}
