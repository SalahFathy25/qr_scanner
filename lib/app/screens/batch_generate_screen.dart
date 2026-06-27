import 'package:flutter/material.dart';
import 'package:qr_code/core/constants/app_constants.dart';

class BatchGenerateScreen extends StatefulWidget {
  final void Function(String title, String data, String category) onGenerate;

  const BatchGenerateScreen({super.key, required this.onGenerate});

  @override
  State<BatchGenerateScreen> createState() => _BatchGenerateScreenState();
}

class _BatchGenerateScreenState extends State<BatchGenerateScreen> {
  final _controller = TextEditingController();
  String _separator = '\n';
  String _category = 'text';
  int _generatedCount = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generate() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final lines = text.split(_separator).map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    if (lines.isEmpty) return;

    setState(() => _generatedCount = 0);

    for (final line in lines) {
      final parts = line.split('|');
      final title = parts.length > 1 ? parts[0].trim() : line.substring(0, line.length > 30 ? 30 : line.length);
      final data = parts.length > 1 ? parts.sublist(1).join('|').trim() : line;
      widget.onGenerate(title, data, _category);
    }

    setState(() => _generatedCount = lines.length);
    _controller.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Generated $_generatedCount QR codes!'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Batch Generate'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
            items: AppConstants.builtInCategories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
            onChanged: (v) => setState(() => _category = v!),
          ),
          const SizedBox(height: 16),
          Row(children: [
            _sepChip('New Line', '\n'),
            const SizedBox(width: 8),
            _sepChip('Comma', ','),
            const SizedBox(width: 8),
            _sepChip('Semicolon', ';'),
          ]),
          const SizedBox(height: 16),
          Text('Data (one per line, use Title|Data format)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: 'My Title|My Data\nTitle2|Data2\n...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          if (_generatedCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('$_generatedCount QR codes generated!', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_2_rounded),
              label: const Text('Generate All'),
              onPressed: _generate,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _sepChip(String label, String sep) {
    final active = _separator == sep;
    return GestureDetector(
      onTap: () => setState(() => _separator = sep),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF6C63FF) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, color: active ? Colors.white : Colors.black87, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
