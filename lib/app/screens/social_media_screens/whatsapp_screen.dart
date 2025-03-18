import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_code/app/cubit/qr_cubit.dart';
import 'package:qr_code/app/widgets/no_qr.dart';
import 'package:qr_code/app/widgets/qr_bottom_sheet.dart';

import '../../widgets/qr_card.dart';

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
        foregroundColor: AppBarTheme.of(context).foregroundColor,
        backgroundColor: AppBarTheme.of(context).backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
          color: AppBarTheme.of(context).iconTheme?.color ?? Colors.white,
        ),
        title: Text(widget.appbarTitle),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed:
                () => qrBottomSheet(
                  context: context,
                  iswhatsapp: true,
                  buttonColor: Colors.green,
                  screenName: 'WhatsApp',
                ),
            icon: const Icon(Icons.add, size: 30),
          ),
        ],
      ),
      body: BlocBuilder<QrCubit, QrState>(
        builder: (context, state) {
          if (state is QrSuccess) {
            final whatsappQrCodes = state.qrCodesByScreen["WhatsApp"] ?? [];
            if (whatsappQrCodes.isEmpty) return noQr();

            return ListView.builder(
              itemCount: whatsappQrCodes.length,
              itemBuilder: (context, index) {
                final qrCode = whatsappQrCodes[index];
                return qrCard(
                  screenName: 'WhatsApp',
                  image: 'assets/logos/whatsapp_logo.png',
                  qrCode: qrCode,
                  qrColor: Color(0xff33D951),
                  index: index,
                  context: context,
                  qrBottomSheet: ({existingTitle, existingData, index}) {
                    qrBottomSheet(
                      context: context,
                      existingTitle: existingTitle,
                      existingData: existingData,
                      screenName: 'WhatsApp',
                      index: index,
                      iswhatsapp: true,
                      buttonColor: Color(0xff33D951),
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
