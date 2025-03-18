import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/qr_cubit.dart';
import '../../widgets/no_qr.dart';
import '../../widgets/qr_bottom_sheet.dart';
import '../../widgets/qr_card.dart';

class InstagramScreen extends StatefulWidget {
  const InstagramScreen({super.key, required this.appbarTitle});
  final String appbarTitle;

  @override
  State<InstagramScreen> createState() => _InstagramScreenState();
}

class _InstagramScreenState extends State<InstagramScreen> {
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
                  screenName: 'Instagram',
                  context: context,
                  iswhatsapp: true,
                  buttonColor: Color(0xffE73D5D),
                ),
            icon: const Icon(Icons.add, size: 30),
          ),
        ],
      ),
      body: BlocBuilder<QrCubit, QrState>(
        builder: (context, state) {
          if (state is QrSuccess) {
            final instagramCodes = state.qrCodesByScreen["WhatsApp"] ?? [];
            if (instagramCodes.isEmpty) return noQr();
            return ListView.builder(
              itemCount: instagramCodes.length,
              itemBuilder: (context, index) {
                final qrCode = instagramCodes[index];
                return qrCard(
                  screenName: 'Instagram',
                  image: 'assets/logos/instagram_logo.png',
                  qrCode: qrCode,
                  qrColor: Color(0xffE73D5D),
                  index: index,
                  context: context,
                  qrBottomSheet: ({existingTitle, existingData, index}) {
                    qrBottomSheet(
                      context: context,
                      existingTitle: existingTitle,
                      existingData: existingData,
                      screenName: 'Instagram' ,
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
