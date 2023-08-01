import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
// screens
import 'package:mealy/screens/auth/RegisterScreen.dart';
import 'package:mealy/screens/auth/ForgotPassScreen.dart';
// components
import 'package:mealy/components/Button.dart';
import 'package:mealy/components/InputField.dart';
import 'package:mealy/components/metode.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/LoginScreen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  void _login() async {
    if (!_form.currentState!.validate()) {
      return;
    }
    _form.currentState!.save();
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: _authData['email']!, password: _authData['sifra']!).then((value) {
        Navigator.pop(context);
        setState(() {
          isLoading = false;
        });
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
  }

  bool isPassHidden = true;
  void changePassVisibility() {
    setState(() {
      isPassHidden = !isPassHidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: medijakveri.size.width * 0.07),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: (medijakveri.size.height - medijakveri.padding.top) * 0.01),
              Text(
                'Prijavite se',
                style: Theme.of(context).textTheme.headline1,
              ),
              Form(
                key: _form,
                child: Container(
                  child: Column(
                    children: [
                      InputField(
                        isLabel: true,
                        isMargin: true,
                        visina: 18,
                        borderRadijus: 10,
                        medijakveri: medijakveri,
                        label: 'Email',
                        focusNode: emailNode,
                        inputAction: TextInputAction.next,
                        inputType: TextInputType.emailAddress,
                        obscureText: false,
                        onChanged: (_) => _form.currentState!.validate(),
                        validator: (value) {
                          if (sifraNode.hasFocus) {
                            return null;
                          } else if (value!.isEmpty) {
                            return 'Molimo Vas da unesete email adresu';
                          }
                        },
                        onSaved: (value) {
                          _authData['email'] = value!;
                        },
                        hintText: 'E-mail',
                      ),
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
                              if (!sifraNode.hasFocus) {
                                return null;
                              } else if (value!.isEmpty) {
                                return 'Molimo Vas da unesete šifru';
                              }
                            },
                            onFieldSubmitted: (_) => _login(),
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
                      isLoading
                          ? const CircularProgressIndicator()
                          : Button(
                              isFullWidth: true,
                              borderRadius: 20,
                              visina: 18,
                              funkcija: () => _login(),
                              buttonText: 'Prijavite se',
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              textColor: Theme.of(context).primaryColor,
                              isBorder: true,
                            ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, ForgotPassScreen.routeName);
                        },
                        child: Text(
                          'Zaboravili ste šifru?',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 150),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(-1, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                      pageBuilder: (context, animation, duration) => RegisterScreen(),
                    ),
                  );
                },
                child: Text(
                  'Nemate nalog?',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
