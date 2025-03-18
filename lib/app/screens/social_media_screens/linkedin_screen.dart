import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/qr_cubit.dart';
import '../../widgets/no_qr.dart';
import '../../widgets/qr_bottom_sheet.dart';
import '../../widgets/qr_card.dart';

class LinkedinScreen extends StatefulWidget {
  const LinkedinScreen({super.key, required this.appbarTitle});
  final String appbarTitle;

  @override
  State<LinkedinScreen> createState() => _LinkedinScreenState();
}

class _LinkedinScreenState extends State<LinkedinScreen> {
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
                  screenName: 'LinkedIn',
                  context: context,
                  iswhatsapp: true,
                  buttonColor: Color(0xff2967B0),
                ),
            icon: const Icon(Icons.add, size: 30),
          ),
        ],
      ),
      body: BlocBuilder<QrCubit, QrState>(
        builder: (context, state) {
          if (state is QrSuccess) {
            final linkedinCodes = state.qrCodesByScreen["LinkedIn"] ?? [];
            if (linkedinCodes.isEmpty) return noQr();
            return ListView.builder(
              itemCount: linkedinCodes.length,
              itemBuilder: (context, index) {
                final qrCode = linkedinCodes[index];
                return qrCard(
                  screenName: 'LinkedIn',
                  image: 'assets/logos/linkedin_logo.png',
                  qrCode: qrCode,
                  qrColor: Color(0xff2967B0),
                  index: index,
                  context: context,
                  qrBottomSheet: ({existingTitle, existingData, index}) {
                    qrBottomSheet(
                      screenName: 'LinkedIn',
                      context: context,
                      existingTitle: existingTitle,
                      existingData: existingData,
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
