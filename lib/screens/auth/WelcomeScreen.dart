import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
//screens
import 'package:mealy/screens/auth/LoginScreen.dart';
import 'package:mealy/screens/auth/RegisterScreen.dart';
//components
import 'package:mealy/components/Button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);
    Future<void> launchInBrowser(String juarel) async {
      final url = Uri.parse(juarel);
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not launch $url');
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: medijakveri.size.width * 0.07),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 45),
                          Text(
                            'Dobrodošli',
                            style: Theme.of(context).textTheme.headline1,
                          ),
                          Text(
                            'Vaš lični kuhar u džepu!',
                            style: Theme.of(context).textTheme.headline3,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  SvgPicture.asset('assets/icons/Logo.svg'),
                  const SizedBox(height: 45),
                  Button(
                    isFullWidth: true,
                    borderRadius: 20,
                    visina: 18,
                    funkcija: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 200),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.7, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            );
                          },
                          pageBuilder: (context, animation, duration) => RegisterScreen(),
                        ),
                      );
                    },
                    buttonText: 'Registrujte se',
                    textColor: Colors.white,
                    isBorder: false,
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 25),
                  Button(
                    isFullWidth: true,
                    borderRadius: 20,
                    visina: 18,
                    funkcija: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 200),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.7, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            );
                          },
                          pageBuilder: (context, animation, duration) => LoginScreen(),
                        ),
                      );
                    },
                    buttonText: 'Prijavite se',
                    textColor: Theme.of(context).primaryColor,
                    isBorder: true,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  // const SizedBox(height: 20),
                ],
              ),
              GestureDetector(
                onTap: () {
                  launchInBrowser('https://bio.link/anes1318');
                },
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'By ',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        Text(
                          'Anes Čoković',
                          style: Theme.of(context).textTheme.headline4!.copyWith(
                                color: Theme.of(context).colorScheme.tertiary,
                                fontSize: 18,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
