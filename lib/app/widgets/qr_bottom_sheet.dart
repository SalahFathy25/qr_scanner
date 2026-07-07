import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:qr_studio/app/models/category_model.dart';
import 'package:qr_studio/core/extensions/context_extensions.dart';

import '../../core/constants/app_constants.dart';

class QrBottomSheet extends StatefulWidget {
  final CategoryModel category;
  final String? existingTitle;
  final String? existingData;
  final int? existingColor;
  final void Function({
    required String title,
    required String data,
    required int color,
  })? onSave;

  const QrBottomSheet({
    super.key,
    required this.category,
    this.existingTitle,
    this.existingData,
    this.existingColor,
    this.onSave,
  });

  static void show({
    required BuildContext context,
    required CategoryModel category,
    String? existingTitle,
    String? existingData,
    int? existingColor,
    void Function({
      required String title,
      required String data,
      required int color,
    })? onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => QrBottomSheet(
        category: category,
        existingTitle: existingTitle,
        existingData: existingData,
        existingColor: existingColor,
        onSave: onSave,
      ),
    );
  }

  @override
  State<QrBottomSheet> createState() => _QrBottomSheetState();
}

class _QrBottomSheetState extends State<QrBottomSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _dataController;
  late int _selectedColor;
  late bool _isEditing;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingTitle ?? '');
    _dataController = TextEditingController(text: widget.existingData ?? '');
    _selectedColor = widget.existingColor ?? widget.category.colorValue;
    _isEditing = widget.existingTitle != null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleController.text.isEmpty || _dataController.text.isEmpty) return;
    widget.onSave?.call(
      title: _titleController.text,
      data: _dataController.text,
      color: _selectedColor,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: context.mediaQuery.viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.category.color.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.category.icon,
                  color: widget.category.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _isEditing
                    ? 'Edit ${widget.category.name} QR'
                    : 'New ${widget.category.name} QR',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _FormLabel('Title'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'e.g. My ${widget.category.name}',
              prefixIcon: const Icon(Icons.title_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _FormLabel('Data'),
          const SizedBox(height: 8),
          _buildDataField(),
          const SizedBox(height: 16),
          _FormLabel('QR Color'),
          const SizedBox(height: 8),
          _ColorPicker(
            currentColor: _selectedColor,
            onChanged: (c) => setState(() => _selectedColor = c),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.category.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _save,
              child: Text(
                _isEditing ? 'Update' : 'Create',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataField() {
    switch (widget.category.id) {
      case 'whatsapp':
        return _WhatsAppField(controller: _dataController, isEditing: _isEditing, existingData: widget.existingData);
      case 'wifi':
        return _WifiFields(controller: _dataController);
      case 'email':
        return _EmailFields(controller: _dataController);
      case 'vcard':
        return _VcardFields(controller: _dataController);
      case 'calendar':
        return _CalendarFields(controller: _dataController);
      case 'location':
        return _LocationFields(controller: _dataController);
      case 'sms':
        return _SmsFields(controller: _dataController);
      default:
        return TextFormField(
          controller: _dataController,
          decoration: InputDecoration(
            hintText: widget.category.id == 'url'
                ? 'https://example.com'
                : 'Enter text',
            prefixIcon: Icon(
              widget.category.id == 'url'
                  ? Icons.link_rounded
                  : Icons.text_fields_rounded,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          maxLines: widget.category.id == 'text' ? 3 : 1,
        );
    }
  }
}

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
      ),
    );
  }
}

// ---- Color Picker ----
class _ColorPicker extends StatelessWidget {
  final int currentColor;
  final ValueChanged<int> onChanged;

  const _ColorPicker({
    required this.currentColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: AppConstants.qrColors.map((c) {
        final isSelected = c.value == currentColor;
        return GestureDetector(
          onTap: () => onChanged(c.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: isSelected
                  ? [BoxShadow(color: c.withAlpha(100), blurRadius: 8)]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

// ---- WhatsApp Field ----
class _WhatsAppField extends StatelessWidget {
  final TextEditingController controller;
  final bool isEditing;
  final String? existingData;

  const _WhatsAppField({
    required this.controller,
    required this.isEditing,
    this.existingData,
  });

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      decoration: InputDecoration(
        labelText: 'WhatsApp Number',
        hintText: 'Enter phone number',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      initialCountryCode: 'EG',
      initialValue: isEditing ? existingData : null,
      onChanged: (p) => controller.text = p.completeNumber,
    );
  }
}

// ---- WiFi Fields ----
class _WifiFields extends StatefulWidget {
  final TextEditingController controller;
  const _WifiFields({required this.controller});

  @override
  State<_WifiFields> createState() => _WifiFieldsState();
}

class _WifiFieldsState extends State<_WifiFields> {
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  String _encryption = 'WPA';

  void _updateData() {
    if (_ssidController.text.isNotEmpty) {
      widget.controller.text =
          'WIFI:S:${_ssidController.text};T:$_encryption;P:${_passwordController.text};;';
    }
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _ssidController,
          decoration: InputDecoration(
            hintText: 'Network name (SSID)',
            prefixIcon: const Icon(Icons.wifi_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onChanged: (_) => _updateData(),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            hintText: 'Password',
            prefixIcon: const Icon(Icons.lock_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onChanged: (_) => _updateData(),
        ),
        const SizedBox(height: 12),
        Row(
          children: ['WPA', 'WEP', 'None']
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _EncryptionChip(
                    label: e,
                    selected: _encryption == e,
                    onTap: () {
                      setState(() => _encryption = e);
                      _updateData();
                    },
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _EncryptionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _EncryptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF6C63FF)
              : (theme.brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ---- Email Fields ----
class _EmailFields extends StatefulWidget {
  final TextEditingController controller;
  const _EmailFields({required this.controller});

  @override
  State<_EmailFields> createState() => _EmailFieldsState();
}

class _EmailFieldsState extends State<_EmailFields> {
  final _toController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();

  void _updateData() {
    final sb = StringBuffer('mailto:${_toController.text}');
    final q = <String>[];
    if (_subjectController.text.isNotEmpty) {
      q.add('subject=${Uri.encodeComponent(_subjectController.text)}');
    }
    if (_bodyController.text.isNotEmpty) {
      q.add('body=${Uri.encodeComponent(_bodyController.text)}');
    }
    if (q.isNotEmpty) sb.write('?${q.join("&")}');
    widget.controller.text = sb.toString();
  }

  @override
  void dispose() {
    _toController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _toController,
          decoration: InputDecoration(
            hintText: 'To: email@example.com',
            prefixIcon: const Icon(Icons.email_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onChanged: (_) => _updateData(),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _subjectController,
          decoration: InputDecoration(
            hintText: 'Subject',
            prefixIcon: const Icon(Icons.subject_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onChanged: (_) => _updateData(),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _bodyController,
          decoration: InputDecoration(
            hintText: 'Body',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          maxLines: 2,
          onChanged: (_) => _updateData(),
        ),
      ],
    );
  }
}

// ---- vCard Fields ----
class _VcardFields extends StatefulWidget {
  final TextEditingController controller;
  const _VcardFields({required this.controller});

  @override
  State<_VcardFields> createState() => _VcardFieldsState();
}

class _VcardFieldsState extends State<_VcardFields> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _orgController = TextEditingController();

  void _updateData() {
    final lines = <String>['BEGIN:VCARD', 'VERSION:3.0'];
    if (_nameController.text.isNotEmpty) {
      lines.add('FN:${_nameController.text}');
    }
    if (_phoneController.text.isNotEmpty) {
      lines.add('TEL:${_phoneController.text}');
    }
    if (_emailController.text.isNotEmpty) {
      lines.add('EMAIL:${_emailController.text}');
    }
    if (_orgController.text.isNotEmpty) {
      lines.add('ORG:${_orgController.text}');
    }
    lines.add('END:VCARD');
    widget.controller.text = lines.join('\n');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _orgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Full Name',
            prefixIcon: const Icon(Icons.person_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onChanged: (_) => _updateData(),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            hintText: 'Phone',
            prefixIcon: const Icon(Icons.phone_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onChanged: (_) => _updateData(),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: 'Email',
            prefixIcon: const Icon(Icons.email_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onChanged: (_) => _updateData(),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _orgController,
          decoration: InputDecoration(
            hintText: 'Organization',
            prefixIcon: const Icon(Icons.business_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onChanged: (_) => _updateData(),
        ),
      ],
    );
  }
}

// ---- Calendar Fields ----
class _CalendarFields extends StatefulWidget {
  final TextEditingController controller;
  const _CalendarFields({required this.controller});

  @override
  State<_CalendarFields> createState() => _CalendarFieldsState();
}

class _CalendarFieldsState extends State<_CalendarFields> {
  final _eventController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  void _updateData() {
    final dateStr =
        '${_selectedDate.year}${_selectedDate.month.toString().padLeft(2, '0')}${_selectedDate.day.toString().padLeft(2, '0')}';
    final timeStr =
        'T${_selectedTime.hour.toString().padLeft(2, '0')}${_selectedTime.minute.toString().padLeft(2, '0')}00';
    final loc = _locationController.text.isNotEmpty
        ? '\\nLocation:${_locationController.text}'
        : '';
    widget.controller.text =
        'BEGIN:VEVENT\\nSUMMARY:${_eventController.text}$loc\\nDTSTART:$dateStr$timeStr\\nEND:VEVENT';
  }

  @override
  void dispose() {
    _eventController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _eventController,
          decoration: InputDecoration(
            hintText: 'Event title',
            prefixIcon: const Icon(Icons.event),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onChanged: (_) => _updateData(),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _locationController,
          decoration: InputDecoration(
            hintText: 'Location (optional)',
            prefixIcon: const Icon(Icons.location_on),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onChanged: (_) => _updateData(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                onPressed: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (d != null) {
                    setState(() => _selectedDate = d);
                    _updateData();
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.access_time, size: 16),
                label: Text(_selectedTime.format(context)),
                onPressed: () async {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (t != null) {
                    setState(() => _selectedTime = t);
                    _updateData();
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---- Location Fields ----
class _LocationFields extends StatefulWidget {
  final TextEditingController controller;
  const _LocationFields({required this.controller});

  @override
  State<_LocationFields> createState() => _LocationFieldsState();
}

class _LocationFieldsState extends State<_LocationFields> {
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _nameController = TextEditingController();

  void _updateData() {
    if (_latController.text.isNotEmpty && _lngController.text.isNotEmpty) {
      final name =
          _nameController.text.isNotEmpty ? ' (${_nameController.text})' : '';
      widget.controller.text =
          'geo:${_latController.text},${_lngController.text}?q=${_latController.text},${_lngController.text}$name';
    }
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Place name (optional)',
            prefixIcon: const Icon(Icons.place),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onChanged: (_) => _updateData(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _latController,
                decoration: InputDecoration(
                  hintText: 'Latitude',
                  prefixIcon: const Icon(Icons.explore),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _updateData(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _lngController,
                decoration: InputDecoration(
                  hintText: 'Longitude',
                  prefixIcon: const Icon(Icons.explore),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _updateData(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---- SMS Fields ----
class _SmsFields extends StatefulWidget {
  final TextEditingController controller;
  const _SmsFields({required this.controller});

  @override
  State<_SmsFields> createState() => _SmsFieldsState();
}

class _SmsFieldsState extends State<_SmsFields> {
  final _messageController = TextEditingController();
  String _phoneNumber = '';

  void _updateData() {
    if (_phoneNumber.isNotEmpty) {
      widget.controller.text =
          'sms:$_phoneNumber${_messageController.text.isNotEmpty ? '?body=${Uri.encodeComponent(_messageController.text)}' : ''}';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntlPhoneField(
          decoration: InputDecoration(
            hintText: 'Phone number',
            labelText: 'Phone',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          initialCountryCode: 'EG',
          onChanged: (p) {
            _phoneNumber = p.completeNumber;
            _updateData();
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _messageController,
          decoration: InputDecoration(
            hintText: 'Message',
            prefixIcon: const Icon(Icons.message),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          maxLines: 3,
          onChanged: (_) => _updateData(),
        ),
      ],
    );
  }
}
