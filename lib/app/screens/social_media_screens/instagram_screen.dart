import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/instagram_cubit/instagram_qr_cubit.dart';
import '../../widgets/no_qr.dart';
import '../../widgets/qr_bottom_sheet.dart';
import '../../widgets/qr_card.dart';
import '../../widgets/qr_view.dart';

class InstagramScreen extends StatefulWidget {
  const InstagramScreen({super.key, required this.appbarTitle});

  final String appbarTitle;

  @override
  State<InstagramScreen> createState() => _InstagramScreenState();
}

class _InstagramScreenState extends State<InstagramScreen> {
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
      buttonColor: Color(0xffE73D5D),
      onPressed: () {
        if (titleController.text.isEmpty || dataController.text.isEmpty) return;

        if (isEditing) {
          context.read<InstagramQrCubit>().updateQrCode(
            editingIndex!,
            titleController.text,
            dataController.text,
          );
        } else {
          context.read<InstagramQrCubit>().addQrCode(
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
      body: BlocBuilder<InstagramQrCubit, InstagramQrState>(
        builder: (context, state) {
          if (state is InstagramQrSuccess) {
            final instagramQrCodes = state.qrCodes;
            if (instagramQrCodes.isEmpty) return noQr();

            return ListView.builder(
              itemCount: instagramQrCodes.length,
              itemBuilder: (context, index) {
                final qrCode = instagramQrCodes[index];
                return qrCard(
                  onTapped: () {
                    qrView(context, qrCode, const Color(0xffE73D5D), false);
                  },
                  onDismissed:
                      () =>
                          context.read<InstagramQrCubit>().deleteQrCode(index),
                  image: 'assets/logos/instagram_logo.png',
                  qrCode: qrCode,
                  qrColor: const Color(0xffE73D5D),
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
