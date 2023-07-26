import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mealy/components/CustomAppbar.dart';
import 'package:mealy/components/metode.dart';

class SettingsScreen extends StatefulWidget {
  static const String routeName = '/SettingsScreen';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool value = false;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);
    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: medijakveri.size.width * 0.07),
        child: Column(
          children: [
            CustomAppBar(
              pageTitle: 'Podešavanja',
              isCenter: true,
              prvaIkonica: Iconsax.back_square,
              prvaIkonicaFunkcija: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifikacije',
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  CupertinoSwitch(
                    value: value,
                    onChanged: (newValue) {
                      setState(() {
                        value = newValue;
                      });
                    },
                    activeColor: Theme.of(context).colorScheme.secondary,
                    thumbColor: Theme.of(context).colorScheme.primary,
                    trackColor: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Metode.showErrorDialog(
                context: context,
                naslov: 'Da li ste sigurni da želite da se odjavite?',
                button1Text: 'Da',
                isButton1Icon: true,
                button1Icon: Icon(
                  Iconsax.tick_circle,
                  color: Colors.white,
                ),
                button1Fun: () async {
                  try {
                    final internetTest = await InternetAddress.lookup('google.com');
                  } catch (error) {
                    Metode.showErrorDialog(
                      message: "Došlo je do greške sa internetom. Provjerite svoju konekciju.",
                      context: context,
                      naslov: 'Greška',
                      button1Text: 'Zatvori',
                      button1Fun: () => {Navigator.pop(context)},
                      isButton2: false,
                    );
                    return;
                  }
                  try {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
                  } catch (e) {
                    Metode.showErrorDialog(
                      message: "Došlo je do greške sa internetom. Provjerite svoju konekciju.",
                      context: context,
                      naslov: 'Greška',
                      button1Text: 'Zatvori',
                      button1Fun: () => {Navigator.pop(context)},
                      isButton2: false,
                    );
                  }
                },
                isButton2: true,
                button2Text: 'Ne',
                isButton2Icon: true,
                button2Icon: Icon(
                  Iconsax.close_circle,
                  color: Colors.white,
                ),
                button2Fun: () {
                  Navigator.pop(context);
                },
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                margin: EdgeInsets.symmetric(vertical: (medijakveri.size.height - medijakveri.padding.top) * 0.02),
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Odjavite se',
                      style: Theme.of(context).textTheme.headline3,
                    ),
                    Icon(
                      Iconsax.logout,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
