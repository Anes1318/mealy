import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mealy/components/Button.dart';
import 'package:mealy/components/CustomAppbar.dart';
import 'package:mealy/components/InputFieldDisabled.dart';
import 'package:mealy/screens/account/AccountEditScreen.dart';
import 'package:provider/provider.dart';

import '../../components/metode.dart';
import '../../providers/MealProvider.dart';
import 'AccountChangePassScreen.dart';
import 'AccountDeleteScreen.dart';

class AccountInfoScreen extends StatefulWidget {
  static const String routeName = '/AccountInfoScreen';
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  bool isLoading = false;
  bool isPassLoading = false;

  Stream<QuerySnapshot<Map<String, dynamic>>>? meals;
  bool? isInternet;
  List<dynamic> ownReceptiIds = [];

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    Provider.of<MealProvider>(context, listen: false).readMeals();
    meals = Provider.of<MealProvider>(context, listen: false).meals;
    isInternet = Provider.of<MealProvider>(context).getIsInternet;
  }

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
                  FirebaseAuth.instance.currentUser!.photoURL == '' || FirebaseAuth.instance.currentUser!.photoURL == null
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
                  isPassLoading
                      ? CircularProgressIndicator()
                      : Button(
                          buttonText: 'Promijenite šifru',
                          borderRadius: 20,
                          visina: 18,
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          textColor: Theme.of(context).colorScheme.primary,
                          isBorder: true,
                          funkcija: () async {
                            Metode.showErrorDialog(
                              context: context,
                              naslov: 'Da li ste sigurni da želite da promijenite šifru?',
                              button1Text: 'Ne',
                              isButton1Icon: true,
                              button1Icon: Icon(
                                Iconsax.close_circle,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              button1Fun: () {
                                Navigator.pop(context);
                              },
                              isButton2: true,
                              button2Text: 'Da',
                              isButton2Icon: true,
                              button2Icon: Icon(
                                Iconsax.tick_circle,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              button2Fun: () async {
                                try {
                                  await InternetAddress.lookup('google.com');
                                } catch (error) {
                                  Navigator.pop(context);

                                  Metode.showErrorDialog(
                                    isJednoPoredDrugog: false,
                                    message: "Došlo je do greške sa internetom. Provjerite svoju konekciju.",
                                    context: context,
                                    naslov: 'Greška',
                                    button1Text: 'Zatvori',
                                    button1Fun: () => Navigator.pop(context),
                                    isButton2: false,
                                  );
                                  return;
                                }

                                try {
                                  setState(() {
                                    isPassLoading = true;
                                  });
                                  Navigator.pop(context);
                                  await FirebaseAuth.instance
                                      .sendPasswordResetEmail(
                                    email: FirebaseAuth.instance.currentUser!.email!,
                                  )
                                      .then((value) {
                                    setState(() {
                                      isPassLoading = false;
                                    });

                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Zahtjev za reset je uspješno poslat na Vaš email.',
                                          style: Theme.of(context).textTheme.headline4,
                                        ),
                                        duration: const Duration(milliseconds: 1500),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Theme.of(context).colorScheme.secondary,
                                        elevation: 4,
                                      ),
                                    );
                                  });
                                } on FirebaseAuthException catch (error) {
                                  setState(() {
                                    isPassLoading = false;
                                  });
                                  Navigator.pop(context);
                                  Metode.showErrorDialog(
                                    isJednoPoredDrugog: false,
                                    message: Metode.getMessageFromErrorCode(error),
                                    context: context,
                                    naslov: 'Greška',
                                    button1Text: 'Zatvori',
                                    button1Fun: () => Navigator.pop(context),
                                    isButton2: false,
                                  );
                                } catch (error) {
                                  setState(() {
                                    isPassLoading = false;
                                  });
                                  Navigator.pop(context);

                                  Metode.showErrorDialog(
                                    isJednoPoredDrugog: false,
                                    message: 'Došlo je do greške',
                                    context: context,
                                    naslov: 'Greška',
                                    button1Text: 'Zatvori',
                                    button1Fun: () => Navigator.pop(context),
                                    isButton2: false,
                                  );
                                }
                              },
                              isJednoPoredDrugog: true,
                            );
                            // await FirebaseAuth.instance.sendPasswordResetEmail(email: "anocoka@gmail.com");
                            // Navigator.push(
                            //   context,
                            //   PageRouteBuilder(
                            //     transitionDuration: const Duration(milliseconds: 150),
                            //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            //       return SlideTransition(
                            //         position: Tween<Offset>(
                            //           begin: const Offset(1, 0),
                            //           end: Offset.zero,
                            //         ).animate(animation),
                            //         child: child,
                            //       );
                            //     },
                            //     pageBuilder: (context, animation, duration) => const AccountChangePassScreen(),
                            //   ),
                            // );
                          },
                          isFullWidth: true,
                        ),
                  StreamBuilder(
                    stream: meals,
                    builder: ((context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(height: 0);
                      }
                      if (snapshot.connectionState == ConnectionState.none) {
                        return const SizedBox(height: 0);
                      }

                      if (!isInternet!) {
                        return const SizedBox(height: 0);
                      }
                      final receptDocs = snapshot.data!.docs;
                      if (receptDocs.isEmpty) {
                        return const SizedBox(height: 0);
                      }
                      receptDocs.sort((a, b) {
                        if (DateTime.parse(a.data()['createdAt']).isAfter(DateTime.parse(b.data()['createdAt']))) {
                          return 0;
                        } else {
                          return 1;
                        }
                      });

                      receptDocs.sort((a, b) {
                        if (DateTime.parse(a.data()['createdAt']).isAfter(DateTime.parse(b.data()['createdAt']))) {
                          return 0;
                        } else {
                          return 1;
                        }
                      });

                      receptDocs.forEach((element) {
                        if (element['userId'] == FirebaseAuth.instance.currentUser!.uid) {
                          ownReceptiIds.add(element.id);
                        }
                      });
                      return const SizedBox(height: 0);
                    }),
                  ),
                  const SizedBox(height: 15),
                  isLoading
                      ? const CircularProgressIndicator()
                      : Button(
                          buttonText: 'Obrišite nalog',
                          borderRadius: 20,
                          visina: 18,
                          backgroundColor: Theme.of(context).colorScheme.tertiary,
                          isFullWidth: true,
                          isBorder: false,
                          funkcija: () async {
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
                                pageBuilder: (context, animation, duration) => const AccountDeleteScreen(),
                              ),
                            );
                          },
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
