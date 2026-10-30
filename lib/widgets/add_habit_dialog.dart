import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Collects and validates demo habit details without saving them.
class AddHabitDialog extends StatefulWidget {
  const AddHabitDialog({super.key});

  @override
  State<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _reminderTimeController = TextEditingController();
  String _frequency = 'Daily';
  TimeOfDay? _reminderTime;
  bool _showValidMessage = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _reminderTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: const Text('Add a Habit'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _fieldDecoration(
                    context,
                    label: 'Habit name',
                    hint: 'For example, take a short walk',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a habit name.';
                    }
                    return null;
                  },
                  onChanged: (_) => _clearValidMessage(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                  decoration: _fieldDecoration(
                    context,
                    label: 'Description (optional)',
                    hint: 'Add a short note',
                  ),
                  onChanged: (_) => _clearValidMessage(),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _frequency,
                  decoration: _fieldDecoration(
                    context,
                    label: 'Frequency',
                    hint: 'Choose a frequency',
                  ).copyWith(prefixIcon: const Icon(Icons.repeat_rounded)),
                  items: const [
                    DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                    DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                  ],
                  onChanged: (frequency) {
                    if (frequency == null) return;
                    setState(() {
                      _frequency = frequency;
                      _showValidMessage = false;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _reminderTimeController,
                  readOnly: true,
                  onTap: _pickReminderTime,
                  decoration:
                      _fieldDecoration(
                        context,
                        label: 'Reminder Time',
                        hint: 'Tap to choose a time',
                      ).copyWith(
                        prefixIcon: const Icon(Icons.access_time_rounded),
                        suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
                      ),
                ),
                if (_showValidMessage) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF163A24)
                          : const Color(0xFFE8F8EC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _validDetailsMessage,
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _validateForm, child: const Text('Continue')),
      ],
    );
  }

  InputDecoration _fieldDecoration(
    BuildContext context, {
    required String label,
    required String hint,
  }) {
    final colors = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(14);

    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: colors.surface,
      border: OutlineInputBorder(borderRadius: borderRadius),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colors.error, width: 1.5),
      ),
    );
  }

  void _validateForm() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _showValidMessage = true;
      });
    }
  }

  Future<void> _pickReminderTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );

    if (pickedTime == null || !mounted) return;

    setState(() {
      _reminderTime = pickedTime;
      _reminderTimeController.text = pickedTime.format(context);
      _showValidMessage = false;
    });
  }

  String get _validDetailsMessage {
    final reminder = _reminderTimeController.text.isEmpty
        ? 'not set'
        : _reminderTimeController.text;

    return 'Valid: ${_nameController.text.trim()}. '
        'Frequency: $_frequency. Reminder: $reminder.';
  }

  void _clearValidMessage() {
    if (_showValidMessage) {
      setState(() {
        _showValidMessage = false;
      });
    }
  }
}
