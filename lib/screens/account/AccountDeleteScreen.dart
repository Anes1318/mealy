import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mealy/components/CustomAppbar.dart';
import 'package:provider/provider.dart';

import '../../components/Button.dart';
import '../../components/metode.dart';
import '../../providers/MealProvider.dart';

class AccountDeleteScreen extends StatefulWidget {
  static const String routeName = '/AccountDeleteScreen';
  const AccountDeleteScreen({super.key});

  @override
  State<AccountDeleteScreen> createState() => _AccountDeleteScreenState();
}

class _AccountDeleteScreenState extends State<AccountDeleteScreen> {
  final _form = GlobalKey<FormState>();

  final emailNode = FocusNode();
  final sifraNode = FocusNode();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    emailNode.addListener(() {
      setState(() {});
    });
    sifraNode.addListener(() {
      setState(() {});
    });
  }

  Map<String, String> _authData = {
    'email': '',
    'sifra': '',
  };

  bool isLoading = false;

  bool isPassHidden = true;
  void changePassVisibility() {
    setState(() {
      isPassHidden = !isPassHidden;
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? meals;
  bool? isInternet;
  List<dynamic> ownReceptiIds = [];
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
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: Size(100, 100),
            child: SafeArea(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: medijakveri.size.width * 0.07),
                padding: EdgeInsets.only(top: (medijakveri.size.height - medijakveri.padding.top) * 0.035, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Iconsax.back_square,
                        size: 34,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: medijakveri.size.width * 0.65,
                      ),
                      child: FittedBox(
                        child: Text(
                          'Obrišite nalog',
                          style: Theme.of(context).textTheme.headline2,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Icon(
                        null,
                        size: 34,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            )),
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: medijakveri.size.width * 0.07),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    'Nećete moći da vratite svoj nalog ako ga obrišete.',
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Da bi obrisali svoj nalog, molimo Vas da unesete šifu.',
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  const SizedBox(height: 30),
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
                  Form(
                    key: _form,
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                bottom: 8,
                                left: medijakveri.size.width * 0.02,
                              ),
                              child: Text(
                                'Šifra',
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ),
                            TextFormField(
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              obscureText: isPassHidden,
                              focusNode: sifraNode,
                              onChanged: (_) => _form.currentState!.validate(),
                              validator: (value) {
                                if (emailNode.hasFocus) {
                                  return null;
                                } else if (value!.isEmpty) {
                                  return 'Molimo Vas da unesete šifru';
                                }
                              },
                              onFieldSubmitted: (_) {
                                FocusManager.instance.primaryFocus?.unfocus();
                                FocusScope.of(context).unfocus();

                                emailNode.unfocus();
                                sifraNode.unfocus();
                              },
                              onSaved: (value) {
                                _authData['sifra'] = value!;
                              },
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                hintText: 'Šifra',
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                suffixIcon: sifraNode.hasFocus
                                    ? IconButton(
                                        onPressed: () => changePassVisibility(),
                                        icon: isPassHidden ? Icon(Iconsax.eye) : Icon(Iconsax.eye_slash),
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ],
              ),
              isLoading
                  ? const CircularProgressIndicator()
                  : Button(
                      isFullWidth: true,
                      borderRadius: 20,
                      visina: 18,
                      funkcija: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        FocusScope.of(context).unfocus();
                        sifraNode.unfocus();

                        Metode.showErrorDialog(
                          context: context,
                          naslov: 'Da li ste sigurni da želite da obrišete svoj nalog?',
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
                            if (!_form.currentState!.validate()) {
                              return;
                            }
                            _form.currentState!.save();
                            try {
                              setState(() {
                                isLoading = true;
                              });
                              await FirebaseAuth.instance.signInWithEmailAndPassword(email: FirebaseAuth.instance.currentUser!.email!, password: _authData['sifra']!).then((value) async {
                                if (ownReceptiIds.isNotEmpty) {
                                  ownReceptiIds.forEach((element) async {
                                    await FirebaseFirestore.instance.collection('recepti').doc(element).delete();
                                    await FirebaseStorage.instance.ref().child('receptImages').child('${element}.jpg').delete();
                                  });
                                }
                                try {
                                  await FirebaseStorage.instance.ref().child('userImages').child('${FirebaseAuth.instance.currentUser!.uid}.jpg').delete();
                                } catch (e) {}

                                await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).delete();

                                await FirebaseAuth.instance.currentUser!.delete().then((value) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                                });
                              });

                              // TODO: TESTIRAJJJ.
                            } on FirebaseAuthException catch (error) {
                              setState(() {
                                isLoading = false;
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
                                isLoading = false;
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
                      },
                      buttonText: 'Obrišite nalog',
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      textColor: Theme.of(context).primaryColor,
                      isBorder: true,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
