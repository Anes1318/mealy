import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mealy/components/Button.dart';
import 'package:mealy/components/InputField.dart';

import '../../components/metode.dart';

class ForgotPassScreen extends StatefulWidget {
  static const String routeName = '/ForgotPassScreen';

  const ForgotPassScreen({super.key});

  @override
  State<ForgotPassScreen> createState() => _ForgotPassScreenState();
}

class _ForgotPassScreenState extends State<ForgotPassScreen> {
  final _form = GlobalKey<FormState>();

  final emailNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    emailNode.addListener(() {
      setState(() {});
    });
  }

  Map<String, String> _authData = {
    'email': '',
  };

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: medijakveri.size.width * 0.07),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Zaboravili ste šifru?',
                  style: Theme.of(context).textTheme.headline1,
                ),
                const SizedBox(height: 110),
                Form(
                  key: _form,
                  child: InputField(
                    isMargin: true,
                    isLabel: true,
                    medijakveri: medijakveri,
                    label: 'Email',
                    hintText: 'E-mail',
                    inputAction: TextInputAction.next,
                    inputType: TextInputType.emailAddress,
                    obscureText: false,
                    focusNode: emailNode,
                    borderRadijus: 10,
                    visina: 18,
                    onChanged: (_) => _form.currentState!.validate(),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Molimo Vas da unesete email adresu';
                      } else if (!value.contains(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"))) {
                        return 'Molimo Vas unesite validnu email adresu';
                      }
                    },
                    onSaved: (value) {
                      _authData['email'] = value!.trim();
                    },
                  ),
                ),
                const SizedBox(height: 40),
                isLoading
                    ? CircularProgressIndicator()
                    : Button(
                        isFullWidth: true,
                        borderRadius: 20,
                        visina: 18,
                        funkcija: () async {
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
                            await FirebaseAuth.instance
                                .sendPasswordResetEmail(
                              email: _authData['email']!,
                            )
                                .then((value) {
                              setState(() {
                                isLoading = false;
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
                              isLoading = false;
                            });

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
                        buttonText: 'Pošalji zahtjev',
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        textColor: Theme.of(context).primaryColor,
                        isBorder: true,
                      ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Nazad na login',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
