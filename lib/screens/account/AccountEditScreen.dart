import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealy/components/InputField.dart';
import 'package:provider/provider.dart';

import '../../components/Button.dart';
import '../../components/metode.dart';
import '../../providers/MealProvider.dart';

class AccountEditScreen extends StatefulWidget {
  static const String routeName = '/AccountEditScreen';

  const AccountEditScreen({super.key});

  @override
  State<AccountEditScreen> createState() => _AccountEditScreenState();
}

class _AccountEditScreenState extends State<AccountEditScreen> {
  final _form = GlobalKey<FormState>();
  bool isLoading = false;
  bool uklonioSliku = false;
  Map<String, String> _authData = {
    'ime': '',
    'prezime': '',
    'email': '',
    'sifra': '',
  };

  final imeNode = FocusNode();
  final prezimeNode = FocusNode();
  final emailNode = FocusNode();

  @override
  void initState() {
    super.initState();
    imeNode.addListener(() {
      setState(() {});
    });
    prezimeNode.addListener(() {
      setState(() {});
    });
    emailNode.addListener(() {
      setState(() {});
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
      uklonioSliku = false;
    });
  }

  void updateUserInfo() async {
    if (!_form.currentState!.validate()) {
      return;
    }
    _form.currentState!.save();

    try {
      String imageUrl = '';

      setState(() {
        isLoading = true;
      });

      try {
        FirebaseAuth.instance.signInWithEmailAndPassword(email: FirebaseAuth.instance.currentUser!.email!, password: _authData['sifra']!);
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
      if (FirebaseAuth.instance.currentUser!.displayName != '${_authData['ime']} ${_authData['prezime']}') {
        await FirebaseAuth.instance.currentUser!.updateDisplayName('${_authData['ime']} ${_authData['prezime']}');
        await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update(
          {
            'userName': '${_authData['ime']} ${_authData['prezime']}',
          },
        );
      }
      if (FirebaseAuth.instance.currentUser!.email != _authData['email']!) {
        await FirebaseAuth.instance.currentUser!.updateEmail(_authData['email']!);
        await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update(
          {
            'email': FirebaseAuth.instance.currentUser!.email,
          },
        );
      }

      if (uklonioSliku == true) {
        await FirebaseAuth.instance.currentUser!.updatePhotoURL(null);
        await FirebaseStorage.instance.ref().child('userImages').child('${FirebaseAuth.instance.currentUser!.uid}.jpg').delete().then((value) async {
          await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update(
            {
              'imageUrl': '',
            },
          );
        });
      } else if (_storedImage != null) {
        await FirebaseStorage.instance.ref().child('userImages').child('${FirebaseAuth.instance.currentUser!.uid}.jpg').putFile(_storedImage!).then((value) async {
          imageUrl = await value.ref.getDownloadURL();
          await FirebaseAuth.instance.currentUser!.updatePhotoURL(imageUrl);
          await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update(
            {
              'imageUrl': imageUrl,
            },
          );
        });
      }

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Uspješno ste uredili svoj nalog',
            style: Theme.of(context).textTheme.headline4,
          ),
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          elevation: 4,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } on FirebaseAuthException catch (error) {
      setState(() {
        isLoading = false;
      });
      print(error);

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

  @override
  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: medijakveri.size.width * 0.07),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SafeArea(
                  child: Container(
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
                              'Uredite nalog',
                              style: Theme.of(context).textTheme.headline2,
                            ),
                          ),
                        ),
                        isLoading
                            ? const Row(
                                children: [
                                  SizedBox(
                                    height: 34,
                                    width: 34,
                                    child: CircularProgressIndicator(),
                                  ),
                                  SizedBox(width: 5),
                                ],
                              )
                            : GestureDetector(
                                onTap: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  FocusScope.of(context).unfocus();
                                  imeNode.unfocus;
                                  prezimeNode.unfocus;
                                  emailNode.unfocus;

                                  updateUserInfo();
                                },
                                child: Icon(
                                  Iconsax.tick_circle,
                                  size: 34,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Metode.showErrorDialog(
                      isJednoPoredDrugog: true,
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
                        color: Theme.of(context).colorScheme.primary,
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
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  },
                  child: Container(
                    width: medijakveri.size.width * 0.4,
                    height: medijakveri.size.width * 0.4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Center(
                        child: (FirebaseAuth.instance.currentUser!.photoURL == '' || FirebaseAuth.instance.currentUser!.photoURL == null || uklonioSliku == true) && _storedImage == null
                            ? Text(
                                'Dodajte sliku',
                                style: Theme.of(context).textTheme.headline2,
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: _storedImage == null
                                    ? Image.network(
                                        '${FirebaseAuth.instance.currentUser!.photoURL}',
                                        fit: BoxFit.cover,
                                        width: medijakveri.size.width * 0.4,
                                        height: medijakveri.size.width * 0.4,
                                      )
                                    : Image.file(
                                        _storedImage!,
                                        fit: BoxFit.fill,
                                        width: medijakveri.size.width * 0.4,
                                        height: medijakveri.size.width * 0.4,
                                      ),
                              ),
                      ),
                    ),
                  ),
                ),
                if ((_storedImage != null || (FirebaseAuth.instance.currentUser!.photoURL != '' && FirebaseAuth.instance.currentUser!.photoURL != null)) && uklonioSliku == false) const SizedBox(height: 10),
                if ((_storedImage != null || (FirebaseAuth.instance.currentUser!.photoURL != '' && FirebaseAuth.instance.currentUser!.photoURL != null)) && uklonioSliku == false)
                  Center(
                    child: Button(
                      isFullWidth: false,
                      buttonText: 'Uklonite sliku',
                      borderRadius: 5,
                      visina: 5,
                      sirina: 10,
                      fontsize: 16,
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      isBorder: false,
                      funkcija: () {
                        setState(() {
                          _storedImage = null;
                          uklonioSliku = true;
                          print(uklonioSliku);
                        });
                      },
                    ),
                  ),
                const SizedBox(height: 20),
                Form(
                  key: _form,
                  child: Column(
                    children: [
                      InputField(
                        isMargin: true,
                        medijakveri: medijakveri,
                        isLabel: true,
                        label: 'Ime',
                        kapitulacija: TextCapitalization.sentences,
                        hintText: 'Ime',
                        focusNode: imeNode,
                        initalValue: FirebaseAuth.instance.currentUser!.displayName!.substring(0, FirebaseAuth.instance.currentUser!.displayName!.indexOf(' ')),
                        inputAction: TextInputAction.next,
                        inputType: TextInputType.name,
                        obscureText: false,
                        borderRadijus: 10,
                        visina: 18,
                        onChanged: (_) => _form.currentState!.validate(),
                        validator: (value) {
                          if (emailNode.hasFocus || prezimeNode.hasFocus) {
                            return null;
                          } else if (value!.isEmpty) {
                            return 'Molimo Vas da unesete ime';
                          } else if (value.length < 2) {
                            return 'Ime mora biti duže';
                          } else if (value.length > 30) {
                            return 'Ime mora biti kraće';
                          } else if (value.contains(RegExp(r'[0-9]')) || value.contains(' ') || !RegExp(r'^[a-zA-Z]+$').hasMatch(value!)) {
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
                        focusNode: prezimeNode,
                        initalValue: FirebaseAuth.instance.currentUser!.displayName!.substring(FirebaseAuth.instance.currentUser!.displayName!.indexOf(' ') + 1),
                        kapitulacija: TextCapitalization.sentences,
                        borderRadijus: 10,
                        inputAction: TextInputAction.next,
                        inputType: TextInputType.text,
                        obscureText: false,
                        visina: 18,
                        onChanged: (_) => _form.currentState!.validate(),
                        validator: (value) {
                          if (imeNode.hasFocus || emailNode.hasFocus) {
                            return null;
                          } else if (value!.isEmpty) {
                            return 'Molimo Vas da unesete prezime';
                          } else if (value.length < 2) {
                            return 'Prezime mora biti duže';
                          } else if (value.length > 30) {
                            return 'Prezime mora biti kraće';
                          } else if (value.contains(RegExp(r'[0-9]')) || value.contains(' ') || !RegExp(r'^[a-zA-Z]+$').hasMatch(value!)) {
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
                        focusNode: emailNode,
                        initalValue: FirebaseAuth.instance.currentUser!.email,
                        inputAction: TextInputAction.next,
                        inputType: TextInputType.emailAddress,
                        obscureText: false,
                        // focusNode: emailNode,
                        borderRadijus: 10,
                        visina: 18,
                        onChanged: (_) => _form.currentState!.validate(),
                        validator: (value) {
                          if (imeNode.hasFocus || prezimeNode.hasFocus) {
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
                    ],
                  ),
                )
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

    imeNode.dispose();
    prezimeNode.dispose();
    emailNode.dispose();
  }
}
