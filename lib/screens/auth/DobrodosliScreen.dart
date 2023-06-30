import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
//screens
import 'package:mealy/screens/auth/LoginScreen.dart';
import 'package:mealy/screens/auth/RegisterScreen.dart';
//components
import 'package:mealy/components/Button.dart';

class DobrodosliScreen extends StatelessWidget {
  const DobrodosliScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: medijakveri.size.width * 0.07),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                  const SizedBox(height: 45),
                  SvgPicture.asset('assets/icons/Logo.svg'),
                ],
              ),
              Column(
                children: [
                  Button(
                    isFullWidth: true,
                    borderRadius: 20,
                    visina: 15,
                    funkcija: () => {
                      Navigator.pushNamed(context, RegisterScreen.routeName),
                    },
                    buttonText: 'Registrujte se',
                    textColor: Colors.white,
                    isBorder: false,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 25),
                  Button(
                    isFullWidth: true,
                    borderRadius: 20,
                    visina: 15,
                    funkcija: () => {
                      Navigator.pushNamed(context, LoginScreen.routeName),
                    },
                    buttonText: 'Prijavite se',
                    textColor: Theme.of(context).primaryColor,
                    isBorder: true,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
