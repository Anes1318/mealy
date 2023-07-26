import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

// screens
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

  File? _storedImage;
  Future<void> _takeImage(isCamera) async {
    final ImagePicker picker = ImagePicker();
    final XFile? imageFile;

    imageFile = await picker.pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 50,
    );
    if (imageFile == null) {
      return;
    }
    CroppedFile? croppedImg = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    );
    if (croppedImg == null) {
      return;
    }
    setState(() {
      _storedImage = File(croppedImg.path);
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
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _authData['email']!, password: _authData['sifra']!).then((value) async {
        String imageUrl = '';

        if (_storedImage != null) {
          final uploadedImage = await FirebaseStorage.instance.ref().child('userImages').child('${value.user!.uid}.jpg').putFile(_storedImage!).then((value) async {
            imageUrl = await value.ref.getDownloadURL();
          });
        }
        await FirebaseAuth.instance.currentUser!.updateDisplayName('${_authData['ime']} ${_authData['prezime']}');
        await FirebaseAuth.instance.currentUser!.updatePhotoURL(imageUrl);
        FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).set({
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'email': FirebaseAuth.instance.currentUser!.email,
          'userName': '${_authData['ime']} ${_authData['prezime']}',
          'imageUrl': imageUrl,
        }).then((value) {
          Navigator.pop(context);

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
    } catch (error) {
      setState(() {
        isLoading = false;
      });

      Metode.showErrorDialog(
        message: 'Došlo je do greške',
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
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: medijakveri.size.width * 0.07),
              child: Column(
                children: [
                  SizedBox(height: (medijakveri.size.height - medijakveri.padding.top) * 0.04),
                  Text(
                    'Registrujte se',
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  SizedBox(height: (medijakveri.size.height - medijakveri.padding.top) * 0.04),
                  Form(
                    key: _form,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Metode.showErrorDialog(
                              context: context,
                              naslov: 'Odakle želite da izaberete sliku?',
                              button1Text: 'Kamera',
                              button1Fun: () {
                                _takeImage(true);
                                Navigator.pop(context);
                              },
                              isButton1Icon: true,
                              button1Icon: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                              isButton2: true,
                              button2Text: 'Galerija',
                              button2Fun: () {
                                _takeImage(false);

                                Navigator.pop(context);
                              },
                              isButton2Icon: true,
                              button2Icon: Icon(
                                Icons.photo,
                                color: Colors.white,
                              ),
                            );
                          },
                          child: Container(
                            width: medijakveri.size.width * 0.4,
                            height: medijakveri.size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Center(
                                child: _storedImage != null
                                    ? Image.file(
                                        _storedImage!,
                                        fit: BoxFit.fill,
                                      )
                                    : Text(
                                        'Dodajte sliku',
                                        style: Theme.of(context).textTheme.headline2,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: (medijakveri.size.height - medijakveri.padding.top) * 0.04),
                        InputField(
                          isMargin: true,
                          medijakveri: medijakveri,
                          isLabel: true,
                          label: 'Ime',
                          kapitulacija: TextCapitalization.sentences,
                          hintText: 'Ime',
                          inputAction: TextInputAction.next,
                          inputType: TextInputType.name,
                          obscureText: false,
                          focusNode: imeNode,
                          borderRadijus: 10,
                          visina: 18,
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
                          },
                        ),
                        InputField(
                          isMargin: true,
                          medijakveri: medijakveri,
                          isLabel: true,
                          label: 'Prezime',
                          hintText: 'Prezime',
                          kapitulacija: TextCapitalization.sentences,
                          borderRadijus: 10,
                          inputAction: TextInputAction.next,
                          inputType: TextInputType.text,
                          obscureText: false,
                          focusNode: prezimeNode,
                          visina: 18,
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
                          },
                        ),
                        InputField(
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
                                child: Text(
                                  'Šifra',
                                  style: Theme.of(context).textTheme.headline4,
                                ),
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
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  suffixIcon: pass1Node.hasFocus
                                      ? IconButton(
                                          onPressed: () => changePassVisibility(),
                                          icon: isPassHidden ? const Icon(Iconsax.eye) : const Icon(Iconsax.eye_slash),
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
                                child: Text(
                                  'Potvrdite šifru',
                                  style: Theme.of(context).textTheme.headline4,
                                ),
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
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  suffixIcon: pass2Node.hasFocus
                                      ? IconButton(
                                          onPressed: () => changePassVisibility2(),
                                          icon: isPassHidden2 ? const Icon(Iconsax.eye) : const Icon(Iconsax.eye_slash),
                                        )
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: (medijakveri.size.height - medijakveri.padding.top) * 0.03),
                        isLoading
                            ? const CircularProgressIndicator()
                            : Button(
                                isFullWidth: true,
                                borderRadius: 20,
                                visina: 18,
                                funkcija: () => {
                                  _register(),
                                },
                                buttonText: 'Registrujte se',
                                backgroundColor: Theme.of(context).colorScheme.secondary,
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
