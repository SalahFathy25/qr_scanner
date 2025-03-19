import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/facebook_cubit/facebook_qr_cubit.dart';
import '../../widgets/no_qr.dart';
import '../../widgets/qr_bottom_sheet.dart';
import '../../widgets/qr_card.dart';
import '../../widgets/qr_view.dart';

class FacebookScreen extends StatefulWidget {
  const FacebookScreen({super.key, required this.appbarTitle});

  final String appbarTitle;

  @override
  State<FacebookScreen> createState() => _FacebookScreenState();
}

class _FacebookScreenState extends State<FacebookScreen> {
  bool isEditing = false;
  int? editingIndex;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController dataController = TextEditingController();

  void openQrBottomSheet({
    String? existingTitle,
    String? existingData,
    int? index,
  }) {
    setState(() {
      isEditing = index != null;
      editingIndex = index;

      titleController.text = existingTitle ?? '';
      dataController.text = existingData ?? '';
    });

    qrBottomSheet(
      context: context,
      titleController: titleController,
      dataController: dataController,
      existingTitle: existingTitle,
      existingData: existingData,
      index: index,
      iswhatsapp: false,
      buttonColor: const Color(0xff0F8FF2),
      onPressed: () {
        if (titleController.text.isEmpty || dataController.text.isEmpty) return;

        if (isEditing) {
          context.read<FacebookQrCubit>().updateQrCode(
            editingIndex!,
            titleController.text,
            dataController.text,
          );
        } else {
          context.read<FacebookQrCubit>().addQrCode(
            titleController.text,
            dataController.text,
          );
        }

        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: AppBarTheme.of(context).foregroundColor,
        backgroundColor: AppBarTheme.of(context).backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.appbarTitle),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => openQrBottomSheet(),
            icon: const Icon(Icons.add, size: 30),
          ),
        ],
      ),
      body: BlocBuilder<FacebookQrCubit, FacebookQrState>(
        builder: (context, state) {
          if (state is FacebookQrSuccess) {
            final facebookQrCodes = state.qrCodes;
            if (facebookQrCodes.isEmpty) return noQr();

            return ListView.builder(
              itemCount: facebookQrCodes.length,
              itemBuilder: (context, index) {
                final qrCode = facebookQrCodes[index];
                return qrCard(
                  onTapped: () {
                    qrView(context, qrCode, const Color(0xff0F8FF2), false);
                  },
                  onDismissed:
                      () => context.read<FacebookQrCubit>().deleteQrCode(index),
                  image: 'assets/logos/facebook_logo.png',
                  qrCode: qrCode,
                  qrColor: const Color(0xff0F8FF2),
                  index: index,
                  context: context,
                  qrBottomSheet: ({existingTitle, existingData, index}) {
                    openQrBottomSheet(
                      existingTitle: existingTitle,
                      existingData: existingData,
                      index: index,
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
