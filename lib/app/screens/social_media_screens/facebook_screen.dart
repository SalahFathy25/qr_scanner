import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/qr_cubit.dart';
import '../../widgets/no_qr.dart';
import '../../widgets/qr_bottom_sheet.dart';
import '../../widgets/qr_card.dart';

class FacebookScreen extends StatefulWidget {
  const FacebookScreen({super.key, required this.appbarTitle});

  final String appbarTitle;

  @override
  State<FacebookScreen> createState() => _FacebookScreenState();
}

class _FacebookScreenState extends State<FacebookScreen> {
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
                  screenName: 'Facebook',
                  context: context,
                  iswhatsapp: true,
                  buttonColor: Color(0xff0F8FF2),
                ),
            icon: const Icon(Icons.add, size: 30),
          ),
        ],
      ),
      body: BlocBuilder<QrCubit, QrState>(
        builder: (context, state) {
          if (state is QrSuccess) {
            final facebookQrCodes = state.qrCodesByScreen["WhatsApp"] ?? [];
            if (facebookQrCodes.isEmpty) return noQr();
            return ListView.builder(
              itemCount: facebookQrCodes.length,
              itemBuilder: (context, index) {
                final qrCode = facebookQrCodes[index];
                return qrCard(
                  screenName: 'Facebook',
                  image: 'assets/logos/facebook_logo.png',
                  qrCode: qrCode,
                  qrColor: Color(0xff0F8FF2),
                  index: index,
                  context: context,
                  qrBottomSheet: ({existingTitle, existingData, index}) {
                    qrBottomSheet(
                      context: context,
                      existingTitle: existingTitle,
                      existingData: existingData,
                      screenName: 'Facebook' ,
                      index: index,
                      buttonColor: Colors.blue,
                      iswhatsapp: false,
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
