import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_code/cubit/qr_cubit.dart';
import 'package:qr_code/widgets/no_qr.dart';
import 'package:qr_code/widgets/qr_bottom_sheet.dart';

import '../widgets/qr_card.dart';

class WhatsappScreen extends StatefulWidget {
  const WhatsappScreen({super.key, required this.appbarTitle});
  final String appbarTitle;

  @override
  State<WhatsappScreen> createState() => _WhatsappScreenState();
}

class _WhatsappScreenState extends State<WhatsappScreen> {
  String qrData = "";
  bool isEditing = false;
  int? editingIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appbarTitle),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => qrBottomSheet(context: context , iswhatsapp: true),
            icon: const Icon(Icons.add, size: 30),
          ),
        ],
      ),
      body: BlocBuilder<QrCubit, QrState>(
        builder: (context, state) {
          if (state is QrSuccess) {
            return ListView.builder(
              itemCount: state.qrCodes.length,
              itemBuilder: (context, index) {
                final qrCode = state.qrCodes[index];
                return qrCard(
                  qrCode: qrCode,
                  index: index,
                  context: context,
                  qrBottomSheet: ({existingTitle, existingData, index}) {
                    qrBottomSheet(
                      context: context,
                      existingTitle: existingTitle,
                      existingData: existingData,
                      index: index,
                      iswhatsapp: true
                    );
                  },
                );
              },
            );
          }
          return noQr();
        },
      ),
    );
  }
}
