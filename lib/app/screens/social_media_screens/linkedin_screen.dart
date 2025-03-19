// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../data/whatsapp_cubit/whatsapp_qr_cubit.dart';
// import '../../widgets/no_qr.dart';
// import '../../widgets/qr_bottom_sheet.dart';
// import '../../widgets/qr_card.dart';

// class LinkedinScreen extends StatefulWidget {
//   const LinkedinScreen({super.key, required this.appbarTitle});
//   final String appbarTitle;

//   @override
//   State<LinkedinScreen> createState() => _LinkedinScreenState();
// }

// class _LinkedinScreenState extends State<LinkedinScreen> {
//   String qrData = "";
//   bool isEditing = false;
//   int? editingIndex;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         foregroundColor: AppBarTheme.of(context).foregroundColor,
//         backgroundColor: AppBarTheme.of(context).backgroundColor,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded),
//           onPressed: () => Navigator.pop(context),
//           color: AppBarTheme.of(context).iconTheme?.color ?? Colors.white,
//         ),
//         title: Text(widget.appbarTitle),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             onPressed:
//                 () => qrBottomSheet(
//                   qrType: QrType.linkedin,
//                   context: context,
//                   iswhatsapp: true,
//                   buttonColor: Color(0xff2967B0),
//                 ),
//             icon: const Icon(Icons.add, size: 30),
//           ),
//         ],
//       ),
//       body: BlocBuilder<QrCubit, QrState>(
//         builder: (context, state) {
//           if (state is QrSuccess) {
//             return ListView.builder(
//               itemCount: state.qrCodes.length,
//               itemBuilder: (context, index) {
//                 final qrCode = state.qrCodes[index];
//                 return qrCard(
//                   image: 'assets/logos/linkedin_logo.png',
//                   qrCode: qrCode,
//                   qrColor: Color(0xff2967B0),
//                   index: index,
//                   context: context,
//                   qrBottomSheet: ({existingTitle, existingData, index}) {
//                     qrBottomSheet(
//                       qrType: QrType.linkedin,
//                       context: context,
//                       existingTitle: existingTitle,
//                       existingData: existingData,
//                       index: index,
//                       buttonColor: Colors.blue,
//                       iswhatsapp: false,
//                     );
//                   },
//                 );
//               },
//             );
//           }
//           return noQr();
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_code/app/data/linkedin_cubit/linkedin_qr_cubit.dart';

import '../../data/instagram_cubit/instagram_qr_cubit.dart';
import '../../widgets/no_qr.dart';
import '../../widgets/qr_bottom_sheet.dart';
import '../../widgets/qr_card.dart';
import '../../widgets/qr_view.dart';

class LinkedinScreen extends StatefulWidget {
  const LinkedinScreen({super.key, required this.appbarTitle});

  final String appbarTitle;

  @override
  State<LinkedinScreen> createState() => _LinkedinScreenState();
}

class _LinkedinScreenState extends State<LinkedinScreen> {
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
      buttonColor: Color(0xff2967B0),
      onPressed: () {
        if (titleController.text.isEmpty || dataController.text.isEmpty) return;

        if (isEditing) {
          context.read<LinkedinQrCubit>().updateQrCode(
            editingIndex!,
            titleController.text,
            dataController.text,
          );
        } else {
          context.read<LinkedinQrCubit>().addQrCode(
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
      body: BlocBuilder<LinkedinQrCubit, LinkedinQrState>(
        builder: (context, state) {
          if (state is LinkedinQrSuccess) {
            final likedInQrCodes = state.qrCodes;
            if (likedInQrCodes.isEmpty) return noQr();

            return ListView.builder(
              itemCount: likedInQrCodes.length,
              itemBuilder: (context, index) {
                final qrCode = likedInQrCodes[index];
                return qrCard(
                  onTapped: () {
                    qrView(context, qrCode, const Color(0xff2967B0), false);
                  },
                  onDismissed:
                      () =>
                          context.read<InstagramQrCubit>().deleteQrCode(index),
                  image: 'assets/logos/linkedin_logo.png',
                  qrCode: qrCode,
                  qrColor: const Color(0xff2967B0),
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
