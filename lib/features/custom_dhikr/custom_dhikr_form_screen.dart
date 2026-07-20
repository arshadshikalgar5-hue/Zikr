import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/custom_dhikr_repository.dart';

/// Add/edit form for a custom dhikr. Pass [entry] to edit an existing one;
/// leave it null to create a new one.
class CustomDhikrFormScreen extends ConsumerStatefulWidget {
  const CustomDhikrFormScreen({super.key, this.entry});

  final CustomDhikrEntry? entry;

  @override
  ConsumerState<CustomDhikrFormScreen> createState() =>
      _CustomDhikrFormScreenState();
}

class _CustomDhikrFormScreenState
    extends ConsumerState<CustomDhikrFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _textController;
  late final TextEditingController _transliterationController;
  late final TextEditingController _meaningController;

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.entry?.text);
    _transliterationController = TextEditingController(
      text: widget.entry?.transliteration,
    );
    _meaningController = TextEditingController(text: widget.entry?.meaning);
  }

  @override
  void dispose() {
    _textController.dispose();
    _transliterationController.dispose();
    _meaningController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(customDhikrProvider.notifier);
    if (_isEditing) {
      notifier.update(
        widget.entry!.copyWith(
          text: _textController.text,
          transliteration: _transliterationController.text,
          meaning: _meaningController.text,
        ),
      );
    } else {
      notifier.add(
        text: _textController.text,
        transliteration: _transliterationController.text,
        meaning: _meaningController.text,
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Dhikr' : 'Add Dhikr')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    labelText: 'Dhikr text',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  textInputAction: TextInputAction.next,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter the dhikr text'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _transliterationController,
                  decoration: const InputDecoration(
                    labelText: 'Transliteration (optional)',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _meaningController,
                  decoration: const InputDecoration(
                    labelText: 'Meaning (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
