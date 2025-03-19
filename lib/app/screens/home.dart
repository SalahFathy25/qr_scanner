import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_code/app/data/facebook_cubit/facebook_qr_cubit.dart';
import 'package:qr_code/app/data/instagram_cubit/instagram_qr_cubit.dart';
import 'package:qr_code/app/data/linkedin_cubit/linkedin_qr_cubit.dart';
import 'package:qr_code/app/data/whatsapp_cubit/whatsapp_qr_cubit.dart';
import 'package:qr_code/app/screens/social_media_screens/facebook_screen.dart';
import 'package:qr_code/app/screens/social_media_screens/instagram_screen.dart';
import 'package:qr_code/app/screens/social_media_screens/linkedin_screen.dart';
import 'package:qr_code/app/screens/social_media_screens/whatsapp_screen.dart';
import 'package:qr_code/app/widgets/custom_home_button.dart';
import 'package:qr_code/app/screens/scan_qr_code.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "QR Code Generator",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => const ScanQrCode()),
              );
            },
            icon: const Icon(Icons.qr_code_scanner_rounded),
            iconSize: 30,
          ),
        ],
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            customHomeButton(
              context,
              image: 'assets/logos/whatsapp_logo.png',
              onPressed:
                  () => navigateTo(
                    context,
                    BlocProvider(
                      create: (context) => WhatsappQrCubit(),
                      child: const WhatsappScreen(
                        appbarTitle: 'Whatsapp Generate QR Code',
                      ),
                    ),
                  ),
              title: 'Whatsapp Generate QR Code',
            ),

            customHomeButton(
              context,
              image: 'assets/logos/facebook_logo.png',
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder:
                        (context) => BlocProvider(
                          create: (context) => FacebookQrCubit(),
                          child: FacebookScreen(
                            appbarTitle: 'Facebook Generate QR Code',
                          ),
                        ),
                  ),
                );
              },
              title: 'Facebook Generate QR Code',
            ),

            customHomeButton(
              context,
              image: 'assets/logos/instagram_logo.png',
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder:
                        (context) => BlocProvider(
                          create: (context) => InstagramQrCubit(),
                          child: InstagramScreen(
                            appbarTitle: 'Instagram Generate QR Code',
                          ),
                        ),
                  ),
                );
              },
              title: 'Instagram Generate QR Code',
            ),

            customHomeButton(
              context,
              image: 'assets/logos/linkedin_logo.png',
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder:
                        (context) => BlocProvider(
                          create: (context) => LinkedinQrCubit(),
                          child: LinkedinScreen(
                            appbarTitle: 'LinkedIn Generate QR Code',
                          ),
                        ),
                  ),
                );
              },
              title: 'LinkedIn Generate QR Code',
            ),

            Spacer(),
            Text(
              'Made with ❤️ by Salah',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
