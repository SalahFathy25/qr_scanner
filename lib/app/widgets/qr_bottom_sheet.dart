import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:qr_code/app/models/category_model.dart';

void showQrBottomSheet({
  required BuildContext context,
  required CategoryModel category,
  String? existingTitle,
  String? existingData,
  int? existingColor,
  void Function({required String title, required String data, required int color})? onSave,
}) {
  final titleController = TextEditingController(text: existingTitle ?? '');
  final dataController = TextEditingController(text: existingData ?? '');
  int selectedColor = existingColor ?? category.colorValue;
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
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
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
                        color: category.color.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(category.icon, color: category.color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEditing ? 'Edit ${category.name} QR' : 'New ${category.name} QR',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Title', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
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
                Text('Data', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                if (category.id == 'whatsapp')
                  IntlPhoneField(
                    decoration: InputDecoration(
                      labelText: 'WhatsApp Number',
                      hintText: 'Enter phone number',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    initialCountryCode: 'EG',
                    initialValue: isEditing ? existingData : null,
                    onChanged: (phone) => dataController.text = phone.completeNumber,
                  )
                else if (category.id == 'wifi')
                  _wifiFields(dataController)
                else if (category.id == 'email')
                  _emailFields(dataController)
                else if (category.id == 'vcard')
                  _vcardFields(dataController)
                else
                  TextFormField(
                    controller: dataController,
                    decoration: InputDecoration(
                      hintText: category.id == 'url' ? 'https://example.com' : 'Enter text',
                      prefixIcon: Icon(
                        category.id == 'url' ? Icons.link_rounded : Icons.text_fields_rounded,
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    maxLines: category.id == 'text' ? 3 : 1,
                  ),
                const SizedBox(height: 16),
                Text('QR Color', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                _colorPicker(selectedColor, (color) {
                  setSheetState(() => selectedColor = color);
                }),
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
                      if (category.id == 'whatsapp' && dataController.text.isEmpty) return;
                      onSave?.call(
                        title: titleController.text,
                        data: dataController.text,
                        color: selectedColor,
                      );
                      Navigator.pop(ctx);
                    },
                    child: Text(
                      isEditing ? 'Update' : 'Create',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
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

Widget _wifiFields(TextEditingController controller) {
  final ssidController = TextEditingController();
  final passwordController = TextEditingController();
  String encryption = 'WPA';

  return StatefulBuilder(
    builder: (context, setState) {
      void updateData() {
        if (ssidController.text.isNotEmpty) {
          controller.text = 'WIFI:S:${ssidController.text};T:$encryption;P:${passwordController.text};;';
        }
      }

      return Column(
        children: [
          TextFormField(
            controller: ssidController,
            decoration: InputDecoration(
              hintText: 'Network name (SSID)',
              prefixIcon: const Icon(Icons.wifi_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onChanged: (_) => updateData(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: const Icon(Icons.lock_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onChanged: (_) => updateData(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _encryptionChip('WPA', encryption, (v) {
                setState(() { encryption = v; updateData(); });
              }),
              const SizedBox(width: 8),
              _encryptionChip('WEP', encryption, (v) {
                setState(() { encryption = v; updateData(); });
              }),
              const SizedBox(width: 8),
              _encryptionChip('None', encryption, (v) {
                setState(() { encryption = v; updateData(); });
              }),
            ],
          ),
        ],
      );
    },
  );
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
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    ),
  );
}

Widget _emailFields(TextEditingController controller) {
  final toController = TextEditingController();
  final subjectController = TextEditingController();
  final bodyController = TextEditingController();

  void updateData() {
    final params = StringBuffer('mailto:${toController.text}');
    final queryParams = <String>[];
    if (subjectController.text.isNotEmpty) {
      queryParams.add('subject=${Uri.encodeComponent(subjectController.text)}');
    }
    if (bodyController.text.isNotEmpty) {
      queryParams.add('body=${Uri.encodeComponent(bodyController.text)}');
    }
    if (queryParams.isNotEmpty) {
      params.write('?${queryParams.join("&")}');
    }
    controller.text = params.toString();
  }

  return Column(
    children: [
      TextFormField(
        controller: toController,
        decoration: InputDecoration(
          hintText: 'To: email@example.com',
          prefixIcon: const Icon(Icons.email_rounded),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onChanged: (_) => updateData(),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: subjectController,
        decoration: InputDecoration(
          hintText: 'Subject',
          prefixIcon: const Icon(Icons.subject_rounded),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onChanged: (_) => updateData(),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: bodyController,
        decoration: InputDecoration(
          hintText: 'Body',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        maxLines: 2,
        onChanged: (_) => updateData(),
      ),
    ],
  );
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

  return Column(
    children: [
      TextFormField(
        controller: nameController,
        decoration: InputDecoration(
          hintText: 'Full Name',
          prefixIcon: const Icon(Icons.person_rounded),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onChanged: (_) => updateData(),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: phoneController,
        decoration: InputDecoration(
          hintText: 'Phone',
          prefixIcon: const Icon(Icons.phone_rounded),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onChanged: (_) => updateData(),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: emailController,
        decoration: InputDecoration(
          hintText: 'Email',
          prefixIcon: const Icon(Icons.email_rounded),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onChanged: (_) => updateData(),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: orgController,
        decoration: InputDecoration(
          hintText: 'Organization',
          prefixIcon: const Icon(Icons.business_rounded),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onChanged: (_) => updateData(),
      ),
    ],
  );
}

Widget _colorPicker(int currentColor, void Function(int) onChanged) {
  final colors = [
    0xFF000000, 0xFF6C63FF, 0xFF33D951, 0xFF0F8FF2,
    0xFFE73D5D, 0xFF2967B0, 0xFFE53935, 0xFFFB8C00,
    0xFF43A047, 0xFF7B1FA2, 0xFF00BCD4, 0xFF795548,
  ];

  return Wrap(
    spacing: 10,
    runSpacing: 10,
    children: colors.map((c) {
      final isSelected = c == currentColor;
      return GestureDetector(
        onTap: () => onChanged(c),
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: Color(c),
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: Colors.white, width: 3)
                : null,
            boxShadow: isSelected
                ? [BoxShadow(color: Color(c).withAlpha(100), blurRadius: 8)]
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
