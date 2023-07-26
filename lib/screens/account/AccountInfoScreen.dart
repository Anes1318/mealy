import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mealy/components/Button.dart';
import 'package:mealy/components/CustomAppbar.dart';
import 'package:mealy/components/InputField.dart';
import 'package:mealy/components/InputFieldDisabled.dart';

class AccountInfoScreen extends StatelessWidget {
  static const String routeName = '/AccountInfoScreen';
  const AccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print(FirebaseAuth.instance.currentUser!.phoneNumber);
    final medijakveri = MediaQuery.of(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: medijakveri.size.width * 0.07),
          child: Column(
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
                  // vodi do edit strane
                },
              ),
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
              InputFieldDisabled(
                medijakveri: medijakveri,
                label: 'Telefon',
                text: FirebaseAuth.instance.currentUser!.phoneNumber == null
                    ? 'Niste dodali broj telefona'
                    : FirebaseAuth.instance.currentUser!.phoneNumber == ''
                        ? 'Niste dodali broj telefona'
                        : FirebaseAuth.instance.currentUser!.phoneNumber!,
              ),
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
        ),
      ),
    );
  }
}
