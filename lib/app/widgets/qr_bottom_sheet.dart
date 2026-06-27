import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:qr_code/app/models/category_model.dart';
import 'package:qr_code/core/constants/app_constants.dart';

void showQrBottomSheet({
  required BuildContext context,
  required CategoryModel category,
  String? existingTitle,
  String? existingData,
  int? existingColor,
  int? gradientStart,
  int? gradientEnd,
  bool hasLogo = false,
  void Function({
    required String title,
    required String data,
    required int color,
    int? gradientStart,
    int? gradientEnd,
    bool hasLogo,
  })? onSave,
}) {
  final titleController = TextEditingController(text: existingTitle ?? '');
  final dataController = TextEditingController(text: existingData ?? '');
  int selectedColor = existingColor ?? category.colorValue;
  int? selectedGradientStart = gradientStart;
  int? selectedGradientEnd = gradientEnd;
  bool logoEnabled = hasLogo;
  bool isEditing = existingTitle != null;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                )),
                const SizedBox(height: 16),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: category.color.withAlpha(30), borderRadius: BorderRadius.circular(12)),
                    child: Icon(category.icon, color: category.color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(isEditing ? 'Edit ${category.name} QR' : 'New ${category.name} QR',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 20),
                _label('Title'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'e.g. My ${category.name}',
                    prefixIcon: const Icon(Icons.title_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 16),
                _label('Data'),
                const SizedBox(height: 8),
                _buildDataField(category, dataController, isEditing, existingData),
                const SizedBox(height: 16),
                _label('QR Color'),
                const SizedBox(height: 8),
                _colorPicker(selectedColor, (c) => setSheetState(() => selectedColor = c)),
                const SizedBox(height: 12),
                Row(children: [
                  _toggleLabel('Gradient'),
                  const SizedBox(width: 8),
                  Switch(
                    value: selectedGradientStart != null && selectedGradientEnd != null,
                    onChanged: (v) {
                      setSheetState(() {
                        if (v) {
                          selectedGradientStart = AppConstants.gradientPresets[0].value;
                          selectedGradientEnd = AppConstants.gradientPresets[1].value;
                        } else {
                          selectedGradientStart = null;
                          selectedGradientEnd = null;
                        }
                      });
                    },
                  ),
                  const Spacer(),
                  _toggleLabel('Logo'),
                  const SizedBox(width: 8),
                  Switch(
                    value: logoEnabled,
                    onChanged: (v) => setSheetState(() => logoEnabled = v),
                  ),
                ]),
                if (selectedGradientStart != null && selectedGradientEnd != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: AppConstants.gradientPresets.length ~/ 2,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final a = AppConstants.gradientPresets[i * 2];
                        final b = AppConstants.gradientPresets[i * 2 + 1];
                        final active = a.value == selectedGradientStart && b.value == selectedGradientEnd;
                        return GestureDetector(
                          onTap: () => setSheetState(() { selectedGradientStart = a.value; selectedGradientEnd = b.value; }),
                          child: Container(
                            width: 48, height: 36,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [a, b]),
                              borderRadius: BorderRadius.circular(10),
                              border: active ? Border.all(color: Colors.white, width: 3) : null,
                            ),
                            child: active ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: category.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      if (titleController.text.isEmpty || dataController.text.isEmpty) return;
                      onSave?.call(
                        title: titleController.text,
                        data: dataController.text,
                        color: selectedColor,
                        gradientStart: selectedGradientStart,
                        gradientEnd: selectedGradientEnd,
                        hasLogo: logoEnabled,
                      );
                      Navigator.pop(ctx);
                    },
                    child: Text(isEditing ? 'Update' : 'Create', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _label(String text) => Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700));

Widget _toggleLabel(String text) => Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500));

Widget _buildDataField(CategoryModel category, TextEditingController controller, bool isEditing, String? existingData) {
  switch (category.id) {
    case 'whatsapp':
      return IntlPhoneField(
        decoration: InputDecoration(
          labelText: 'WhatsApp Number', hintText: 'Enter phone number',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        initialCountryCode: 'EG',
        initialValue: isEditing ? existingData : null,
        onChanged: (p) => controller.text = p.completeNumber,
      );
    case 'wifi':
      return _wifiFields(controller);
    case 'email':
      return _emailFields(controller);
    case 'vcard':
      return _vcardFields(controller);
    case 'calendar':
      return _calendarFields(controller);
    case 'location':
      return _locationFields(controller);
    case 'sms':
      return _smsFields(controller);
    default:
      return TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: category.id == 'url' ? 'https://example.com' : 'Enter text',
          prefixIcon: Icon(category.id == 'url' ? Icons.link_rounded : Icons.text_fields_rounded),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        maxLines: category.id == 'text' ? 3 : 1,
      );
  }
}

Widget _calendarFields(TextEditingController controller) {
  final eventController = TextEditingController();
  final locationController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  void updateData() {
    final dateStr = '${selectedDate.year}${selectedDate.month.toString().padLeft(2, '0')}${selectedDate.day.toString().padLeft(2, '0')}';
    final timeStr = 'T${selectedTime.hour.toString().padLeft(2, '0')}${selectedTime.minute.toString().padLeft(2, '0')}00';
    final loc = locationController.text.isNotEmpty ? '\\nLocation:${locationController.text}' : '';
    controller.text = 'BEGIN:VEVENT\\nSUMMARY:${eventController.text}$loc\\nDTSTART:$dateStr$timeStr\\nEND:VEVENT';
  }

  return Column(children: [
    TextFormField(
      controller: eventController,
      decoration: InputDecoration(hintText: 'Event title', prefixIcon: const Icon(Icons.event), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
      onChanged: (_) => updateData(),
    ),
    const SizedBox(height: 12),
    TextFormField(
      controller: locationController,
      decoration: InputDecoration(hintText: 'Location (optional)', prefixIcon: const Icon(Icons.location_on), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
      onChanged: (_) => updateData(),
    ),
    const SizedBox(height: 12),
    _CalendarRow(selectedDate: selectedDate, selectedTime: selectedTime, onDateChanged: (d) { selectedDate = d; updateData(); }, onTimeChanged: (t) { selectedTime = t; updateData(); }),
  ]);
}

Widget _locationFields(TextEditingController controller) {
  final latController = TextEditingController();
  final lngController = TextEditingController();
  final nameController = TextEditingController();

  void updateData() {
    if (latController.text.isNotEmpty && lngController.text.isNotEmpty) {
      final name = nameController.text.isNotEmpty ? ' ($nameController.text)' : '';
      controller.text = 'geo:${latController.text},${lngController.text}?q=${latController.text},${lngController.text}$name';
    }
  }

  return Column(children: [
    TextFormField(
      controller: nameController,
      decoration: InputDecoration(hintText: 'Place name (optional)', prefixIcon: const Icon(Icons.place), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
      onChanged: (_) => updateData(),
    ),
    const SizedBox(height: 12),
    Row(children: [
      Expanded(child: TextFormField(
        controller: latController,
        decoration: InputDecoration(hintText: 'Latitude', prefixIcon: const Icon(Icons.explore), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
        keyboardType: TextInputType.number,
        onChanged: (_) => updateData(),
      )),
      const SizedBox(width: 12),
      Expanded(child: TextFormField(
        controller: lngController,
        decoration: InputDecoration(hintText: 'Longitude', prefixIcon: const Icon(Icons.explore), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
        keyboardType: TextInputType.number,
        onChanged: (_) => updateData(),
      )),
    ]),
  ]);
}

Widget _smsFields(TextEditingController controller) {
  final phoneController = TextEditingController();
  final messageController = TextEditingController();

  void updateData() {
    if (phoneController.text.isNotEmpty) {
      controller.text = 'sms:${phoneController.text}${messageController.text.isNotEmpty ? '?body=${Uri.encodeComponent(messageController.text)}' : ''}';
    }
  }

  return Column(children: [
    IntlPhoneField(
      decoration: InputDecoration(
        hintText: 'Phone number', labelText: 'Phone',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      initialCountryCode: 'EG',
      onChanged: (p) { phoneController.text = p.completeNumber; updateData(); },
    ),
    const SizedBox(height: 12),
    TextFormField(
      controller: messageController,
      decoration: InputDecoration(hintText: 'Message', prefixIcon: const Icon(Icons.message), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
      maxLines: 3,
      onChanged: (_) => updateData(),
    ),
  ]);
}

Widget _wifiFields(TextEditingController controller) {
  final ssidController = TextEditingController();
  final passwordController = TextEditingController();
  String encryption = 'WPA';

  return StatefulBuilder(builder: (context, setState) {
    void updateData() {
      if (ssidController.text.isNotEmpty) {
        controller.text = 'WIFI:S:${ssidController.text};T:$encryption;P:${passwordController.text};;';
      }
    }
    return Column(children: [
      TextFormField(controller: ssidController,
        decoration: InputDecoration(hintText: 'Network name (SSID)', prefixIcon: const Icon(Icons.wifi_rounded), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
        onChanged: (_) => updateData()),
      const SizedBox(height: 12),
      TextFormField(controller: passwordController,
        decoration: InputDecoration(hintText: 'Password', prefixIcon: const Icon(Icons.lock_rounded), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
        onChanged: (_) => updateData()),
      const SizedBox(height: 12),
      Row(children: ['WPA', 'WEP', 'None'].map((e) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: _encryptionChip(e, encryption, (v) { setState(() { encryption = v; updateData(); }); }),
      )).toList()),
    ]);
  });
}

Widget _encryptionChip(String label, String current, void Function(String) onSelected) {
  final selected = label == current;
  return GestureDetector(
    onTap: () => onSelected(label),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF6C63FF) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.w500, fontSize: 13)),
    ),
  );
}

Widget _emailFields(TextEditingController controller) {
  final toController = TextEditingController();
  final subjectController = TextEditingController();
  final bodyController = TextEditingController();

  void updateData() {
    final sb = StringBuffer('mailto:${toController.text}');
    final q = <String>[];
    if (subjectController.text.isNotEmpty) q.add('subject=${Uri.encodeComponent(subjectController.text)}');
    if (bodyController.text.isNotEmpty) q.add('body=${Uri.encodeComponent(bodyController.text)}');
    if (q.isNotEmpty) sb.write('?${q.join("&")}');
    controller.text = sb.toString();
  }

  return Column(children: [
    TextFormField(controller: toController, decoration: InputDecoration(hintText: 'To: email@example.com', prefixIcon: const Icon(Icons.email_rounded), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))), onChanged: (_) => updateData()),
    const SizedBox(height: 12),
    TextFormField(controller: subjectController, decoration: InputDecoration(hintText: 'Subject', prefixIcon: const Icon(Icons.subject_rounded), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))), onChanged: (_) => updateData()),
    const SizedBox(height: 12),
    TextFormField(controller: bodyController, decoration: InputDecoration(hintText: 'Body', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))), maxLines: 2, onChanged: (_) => updateData()),
  ]);
}

Widget _vcardFields(TextEditingController controller) {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final orgController = TextEditingController();

  void updateData() {
    final lines = <String>['BEGIN:VCARD', 'VERSION:3.0'];
    if (nameController.text.isNotEmpty) lines.add('FN:${nameController.text}');
    if (phoneController.text.isNotEmpty) lines.add('TEL:${phoneController.text}');
    if (emailController.text.isNotEmpty) lines.add('EMAIL:${emailController.text}');
    if (orgController.text.isNotEmpty) lines.add('ORG:${orgController.text}');
    lines.add('END:VCARD');
    controller.text = lines.join('\n');
  }

  return Column(children: [
    TextFormField(controller: nameController, decoration: InputDecoration(hintText: 'Full Name', prefixIcon: const Icon(Icons.person_rounded), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))), onChanged: (_) => updateData()),
    const SizedBox(height: 12),
    TextFormField(controller: phoneController, decoration: InputDecoration(hintText: 'Phone', prefixIcon: const Icon(Icons.phone_rounded), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))), onChanged: (_) => updateData()),
    const SizedBox(height: 12),
    TextFormField(controller: emailController, decoration: InputDecoration(hintText: 'Email', prefixIcon: const Icon(Icons.email_rounded), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))), onChanged: (_) => updateData()),
    const SizedBox(height: 12),
    TextFormField(controller: orgController, decoration: InputDecoration(hintText: 'Organization', prefixIcon: const Icon(Icons.business_rounded), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))), onChanged: (_) => updateData()),
  ]);
}

class _CalendarRow extends StatefulWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;
  const _CalendarRow({required this.selectedDate, required this.selectedTime, required this.onDateChanged, required this.onTimeChanged});

  @override
  State<_CalendarRow> createState() => _CalendarRowState();
}

class _CalendarRowState extends State<_CalendarRow> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: OutlinedButton.icon(
        icon: const Icon(Icons.calendar_today, size: 16),
        label: Text('${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}'),
        onPressed: () async {
          final d = await showDatePicker(context: context, initialDate: widget.selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
          if (d != null) widget.onDateChanged(d);
        },
      )),
      const SizedBox(width: 12),
      Expanded(child: OutlinedButton.icon(
        icon: const Icon(Icons.access_time, size: 16),
        label: Text(widget.selectedTime.format(context)),
        onPressed: () async {
          final t = await showTimePicker(context: context, initialTime: widget.selectedTime);
          if (t != null) widget.onTimeChanged(t);
        },
      )),
    ]);
  }
}

Widget _colorPicker(int currentColor, void Function(int) onChanged) {
  return Wrap(
    spacing: 10, runSpacing: 10,
    children: AppConstants.qrColors.map((c) {
      final isSelected = c.value == currentColor;
      return GestureDetector(
        onTap: () => onChanged(c.value),
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: c, borderRadius: BorderRadius.circular(10),
            border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
            boxShadow: isSelected ? [BoxShadow(color: c.withAlpha(100), blurRadius: 8)] : null,
          ),
          child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
        ),
      );
    }).toList(),
  );
}
