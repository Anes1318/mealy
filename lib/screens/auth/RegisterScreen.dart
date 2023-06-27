import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';

// screens
import 'package:mealy/screens/main/BottomNavigationBarScreen.dart';
import 'package:mealy/screens/auth/LoginScreen.dart';
// components
import 'package:mealy/components/Button.dart';
import 'package:mealy/components/InputField.dart';
import 'package:mealy/components/metode.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = '/RegisterScreen';

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  Map<String, String> _authData = {
    'ime': '',
    'prezime': '',
    'email': '',
    'sifra': '',
  };

  final _passwordController = TextEditingController();
  bool isLoading = false;
  final imeNode = FocusNode();
  final prezimeNode = FocusNode();
  final emailNode = FocusNode();
  final pass1Node = FocusNode();
  final pass2Node = FocusNode();

  @override
  void initState() {
    super.initState();
    pass1Node.addListener(() {
      setState(() {});
    });
    imeNode.addListener(() {
      setState(() {});
    });
    prezimeNode.addListener(() {
      setState(() {});
    });
    emailNode.addListener(() {
      setState(() {});
    });
    pass2Node.addListener(() {
      setState(() {});
    });
  }

  bool isPassHidden = true;
  void changePassVisibility() {
    setState(() {
      isPassHidden = !isPassHidden;
    });
  }

  bool isPassHidden2 = true;
  void changePassVisibility2() {
    setState(() {
      isPassHidden2 = !isPassHidden2;
    });
  }

  void _register() async {
    if (!_form.currentState!.validate()) {
      return;
    }
    _form.currentState!.save();
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _authData['email']!, password: _authData['sifra']!).then((value) {
        FirebaseAuth.instance.currentUser!.updateDisplayName('${_authData['ime']} ${_authData['prezime']}').then((value) {
          Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);

          setState(() {
            isLoading = false;
          });
        });
      });
    } on FirebaseAuthException catch (error) {
      setState(() {
        isLoading = false;
      });
      Metode.showErrorDialog(
        message: Metode.getMessageFromErrorCode(error),
        context: context,
        naslov: 'Greška',
        button1Text: 'Zatvori',
        button1Fun: () => {Navigator.pop(context)},
        isButton2: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);
    return Scaffold(
      body: Container(
        alignment: Alignment.bottomCenter,
        margin: EdgeInsets.symmetric(horizontal: medijakveri.size.width * 0.07),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Registrujte se',
                  style: Theme.of(context).textTheme.headline1,
                ),
                SizedBox(height: (medijakveri.size.height - medijakveri.padding.top) * 0.09),
                Form(
                  key: _form,
                  child: Column(
                    children: [
                      InputField(
                          medijakveri: medijakveri,
                          label: 'Ime',
                          hintText: 'Ime',
                          inputAction: TextInputAction.next,
                          inputType: TextInputType.name,
                          obscureText: false,
                          focusNode: imeNode,
                          onChanged: (_) => _form.currentState!.validate(),
                          validator: (value) {
                            if (emailNode.hasFocus || prezimeNode.hasFocus || pass1Node.hasFocus || pass2Node.hasFocus) {
                              return null;
                            } else if (value!.isEmpty) {
                              return 'Molimo Vas da unesete ime';
                            } else if (value.length < 2) {
                              return 'Ime mora biti duže';
                            } else if (value.contains(RegExp(r'[0-9]')) || value.contains(' ')) {
                              return 'Ime smije sadržati samo velika i mala slova i simbole';
                            }
                          },
                          onSaved: (value) {
                            _authData['ime'] = value!.trim();
                          }),
                      InputField(
                          medijakveri: medijakveri,
                          label: 'Prezime',
                          hintText: 'Prezime',
                          inputAction: TextInputAction.next,
                          inputType: TextInputType.text,
                          obscureText: false,
                          focusNode: prezimeNode,
                          onChanged: (_) => _form.currentState!.validate(),
                          validator: (value) {
                            if (imeNode.hasFocus || emailNode.hasFocus || pass1Node.hasFocus || pass2Node.hasFocus) {
                              return null;
                            } else if (value!.isEmpty) {
                              return 'Molimo Vas da unesete prezime';
                            } else if (value.length < 2) {
                              return 'Prezime mora biti duže';
                            } else if (value.contains(RegExp(r'[0-9]')) || value.contains(' ')) {
                              return 'Prezime smije sadržati samo velika i mala slova i simbole';
                            }
                          },
                          onSaved: (value) {
                            _authData['prezime'] = value!.trim();
                          }),
                      InputField(
                        medijakveri: medijakveri,
                        label: 'Email',
                        hintText: 'E-mail',
                        inputAction: TextInputAction.next,
                        inputType: TextInputType.emailAddress,
                        obscureText: false,
                        focusNode: emailNode,
                        onChanged: (_) => _form.currentState!.validate(),
                        validator: (value) {
                          if (imeNode.hasFocus || prezimeNode.hasFocus || pass1Node.hasFocus || pass2Node.hasFocus) {
                            return null;
                          } else if (value!.isEmpty) {
                            return 'Molimo Vas da unesete email adresu';
                          } else if (!value.contains(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"))) {
                            return 'Molimo Vas unesite validnu email adresu';
                          }
                        },
                        onSaved: (value) {
                          _authData['email'] = value!;
                        },
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: (medijakveri.size.height - medijakveri.padding.top) * 0.025),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                bottom: (medijakveri.size.height - medijakveri.padding.top) * 0.005,
                                left: medijakveri.size.width * 0.02,
                              ),
                              child: Text('Šifra'),
                            ),
                            TextFormField(
                              focusNode: pass1Node,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              obscureText: isPassHidden,
                              controller: _passwordController,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(pass2Node);
                              },
                              onChanged: (_) => _form.currentState!.validate(),
                              validator: (value) {
                                if (imeNode.hasFocus || prezimeNode.hasFocus || emailNode.hasFocus || pass2Node.hasFocus) {
                                  return null;
                                } else if (value!.isEmpty || !value.contains(RegExp(r'[A-Za-z]'))) {
                                  return 'Molimo Vas unesite šifru';
                                } else if (value.length < 5) {
                                  return 'Šifra mora imati više od 4 karaktera';
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'Šifra',
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                suffixIcon: pass1Node.hasFocus
                                    ? IconButton(
                                        onPressed: () => changePassVisibility(),
                                        icon: isPassHidden ? Icon(Iconsax.eye) : Icon(Iconsax.eye_slash),
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: (medijakveri.size.height - medijakveri.padding.top) * 0.025),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                bottom: (medijakveri.size.height - medijakveri.padding.top) * 0.005,
                                left: medijakveri.size.width * 0.02,
                              ),
                              child: Text('Potvrdite šifru'),
                            ),
                            TextFormField(
                              focusNode: pass2Node,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              obscureText: isPassHidden2,
                              onChanged: (_) => _form.currentState!.validate(),
                              validator: (value) {
                                if (imeNode.hasFocus || prezimeNode.hasFocus || pass1Node.hasFocus || emailNode.hasFocus) {
                                  return null;
                                } else if (value!.isEmpty) {
                                  return 'Molimo Vas unesite šifru';
                                } else if (value != _passwordController.text) {
                                  return 'Šifre moraju biti iste';
                                }
                              },
                              onSaved: (value) {
                                _authData['sifra'] = value!;
                              },
                              onFieldSubmitted: (_) {
                                FocusManager.instance.primaryFocus?.unfocus();
                                FocusScope.of(context).unfocus();
                                _register();
                              },
                              decoration: InputDecoration(
                                hintText: 'Potvrdite šifru',
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                suffixIcon: pass2Node.hasFocus
                                    ? IconButton(
                                        onPressed: () => changePassVisibility2(),
                                        icon: isPassHidden2 ? Icon(Iconsax.eye) : Icon(Iconsax.eye_slash),
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: (medijakveri.size.height - medijakveri.padding.top) * 0.03),
                      isLoading
                          ? CircularProgressIndicator()
                          : Button(
                              borderRadius: 20,
                              visina: 18,
                              funkcija: () => {
                                _register(),
                              },
                              horizontalMargin: 0,
                              buttonText: 'Registrujte se',
                              color: Theme.of(context).colorScheme.secondary,
                              textColor: Theme.of(context).primaryColor,
                              isBorder: true,
                            ),
                      SizedBox(height: (medijakveri.size.height - medijakveri.padding.top) * 0.03),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
                  },
                  child: Text(
                    'Već imate nalog?',
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pass1Node.dispose();
    pass2Node.dispose();
    imeNode.dispose();
    prezimeNode.dispose();
    emailNode.dispose();
  }
}
