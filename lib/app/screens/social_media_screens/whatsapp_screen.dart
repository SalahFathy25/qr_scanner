import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_code/app/data/whatsapp_cubit/whatsapp_qr_cubit.dart';
import 'package:qr_code/app/widgets/no_qr.dart';
import 'package:qr_code/app/widgets/qr_bottom_sheet.dart';
import '../../widgets/qr_card.dart';
import '../../widgets/qr_view.dart';

class WhatsappScreen extends StatefulWidget {
  const WhatsappScreen({super.key, required this.appbarTitle});
  final String appbarTitle;

  @override
  State<WhatsappScreen> createState() => _WhatsappScreenState();
}

class _WhatsappScreenState extends State<WhatsappScreen> {
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
      iswhatsapp: true,
      buttonColor: const Color(0xff33D951),
      onPressed: () {
        if (titleController.text.isEmpty || dataController.text.isEmpty) return;

        if (isEditing) {
          context.read<WhatsappQrCubit>().updateQrCode(
            editingIndex!,
            titleController.text,
            dataController.text,
          );
        } else {
          context.read<WhatsappQrCubit>().addQrCode(
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
      body: BlocBuilder<WhatsappQrCubit, WhatsappQrState>(
        builder: (context, state) {
          if (state is WhatsappQrSuccess) {
            final whatsappQrCodes = state.qrCodes;
            if (whatsappQrCodes.isEmpty) return noQr();

            return ListView.builder(
              itemCount: whatsappQrCodes.length,
              itemBuilder: (context, index) {
                final qrCode = whatsappQrCodes[index];
                return qrCard(
                  image: 'assets/logos/whatsapp_logo.png',
                  onTapped: () {
                    qrView(context, qrCode, Colors.green, true);
                  },
                  onDismissed:
                      () => context.read<WhatsappQrCubit>().deleteQrCode(index),
                  qrCode: qrCode,
                  qrColor: const Color(0xff33D951),
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
