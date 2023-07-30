import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mealy/components/Button.dart';
import 'package:mealy/components/CustomAppbar.dart';
import 'package:mealy/components/InputField.dart';
import 'package:mealy/components/InputFieldDisabled.dart';
import 'package:mealy/screens/account/AccountEditScreen.dart';
import 'package:provider/provider.dart';

import '../../providers/MealProvider.dart';

class AccountInfoScreen extends StatefulWidget {
  static const String routeName = '/AccountInfoScreen';
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  @override
  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);

    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: medijakveri.size.width * 0.07),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomAppBar(
                pageTitle: 'Nalog',
                isCenter: true,
                prvaIkonica: Iconsax.back_square,
                prvaIkonicaFunkcija: () {
                  Navigator.pop(context);
                },
                drugaIkonica: Iconsax.edit,
                drugaIkonicaFunkcija: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 150),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                      pageBuilder: (context, animation, duration) => const AccountEditScreen(),
                    ),
                  );
                },
              ),
              Column(
                children: [
                  FirebaseAuth.instance.currentUser!.photoURL == ''
                      ? SvgPicture.asset(
                          'assets/icons/Torta.svg',
                          width: medijakveri.size.width * 0.4,
                          height: medijakveri.size.width * 0.4,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            '${FirebaseAuth.instance.currentUser!.photoURL}',
                            fit: BoxFit.cover,
                            width: medijakveri.size.width * 0.4,
                            height: medijakveri.size.width * 0.4,
                          ),
                        ),
                  InputFieldDisabled(
                    medijakveri: medijakveri,
                    label: 'Ime',
                    text: FirebaseAuth.instance.currentUser!.displayName!.substring(0, FirebaseAuth.instance.currentUser!.displayName!.indexOf(' ')),
                  ),
                  InputFieldDisabled(
                    medijakveri: medijakveri,
                    label: 'Prezime',
                    text: FirebaseAuth.instance.currentUser!.displayName!.substring(FirebaseAuth.instance.currentUser!.displayName!.indexOf(' ') + 1),
                  ),
                  InputFieldDisabled(
                    medijakveri: medijakveri,
                    label: 'Email',
                    text: FirebaseAuth.instance.currentUser!.email!,
                  ),
                ],
              ),
              SizedBox(height: (medijakveri.size.height - medijakveri.padding.top) * 0.1),
              Column(
                children: [
                  const SizedBox(height: 10),
                  Button(
                    buttonText: 'Promijenite šifru',
                    borderRadius: 20,
                    visina: 18,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    textColor: Theme.of(context).colorScheme.primary,
                    isBorder: true,
                    funkcija: () {},
                    isFullWidth: true,
                  ),
                  const SizedBox(height: 15),
                  Button(
                    buttonText: 'Obrišite nalog',
                    borderRadius: 20,
                    visina: 18,
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    isBorder: false,
                    funkcija: () {},
                    isFullWidth: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
