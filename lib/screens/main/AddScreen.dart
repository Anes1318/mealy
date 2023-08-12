import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multiple_search_selection/multiple_search_selection.dart';
// screens
import 'package:mealy/screens/main/BottomNavigationBarScreen.dart';
// components
import 'package:mealy/components/InputField.dart';
import '../../models/availableTagovi.dart';
import '../../models/tezina.dart';
import 'package:mealy/components/Button.dart';
import 'package:mealy/components/metode.dart';

class AddScreen extends StatefulWidget {
  AddScreen({
    super.key,
  });

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> with SingleTickerProviderStateMixin {
  final _form = GlobalKey<FormState>();

  final nazivNode = FocusNode();
  final opisNode = FocusNode();
  final brOsobaNode = FocusNode();
  final vrPripremeNode = FocusNode();
  final tagNode = FocusNode();

  List<String> localAvailableTagovi = availableTagovi;

  List<TextEditingController> sastojakInput = [TextEditingController()];
  List<FocusNode> sastojakFokus = [FocusNode()];
  List<TextEditingController> korakInput = [TextEditingController()];
  List<FocusNode> korakFokus = [FocusNode()];

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
      aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
    );
    if (croppedImg == null) {
      return;
    }
    setState(() {
      _storedImage = File(croppedImg.path);
    });
    setState(() {
      slikaValidator = null;
    });
  }

  bool isLoading = false;

  Map<String, dynamic> data = {
    'naziv': '',
    'opis': '',
    'brOsoba': 0,
    'vrPripreme': 0,
  };
  List<String> sastojci = [];
  List<String> koraci = [];
  Tezina? tezina;
  String? strTezina;
  List<String> tagovi = [];
  bool tezinaValidator = false;
  bool tagValidator = false;
  String? slikaValidator;
  int brRecepata = 0;

  final dummyData = {
    'userId': FirebaseAuth.instance.currentUser!.uid,
    'naziv': 'recept',
    'opis': 'opis 1',
    'brOsoba': '5',
    'vrPripreme': '35',
    'tezina': 'Umjereno',
    'sastojci': ['sastojak 1, sastojak 2'],
    'koraci': ['korak 1, korak 2'],
    'tagovi': ['Zdravo, Ručak'],
  };

  void addMealTest() async {
    await FirebaseFirestore.instance.collection('recepti').add(
      {
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'naziv': '${dummyData['naziv']} $brRecepata',
        'opis': dummyData['opis'],
        'brOsoba': dummyData['brOsoba'],
        'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/mealy1318-fabad.appspot.com/o/receptImages%2FPnLqVfm3TduPSOLAlqMC.jpg?alt=media&token=975746f2-27fa-4749-bb76-f6fe44e4a686',
        'vrPripreme': dummyData['vrPripreme'],
        'tezina': dummyData['tezina'],
        'sastojci': dummyData['sastojci'],
        'koraci': dummyData['koraci'],
        'tagovi': dummyData['tagovi'],
        'favorites': {},
        'ratings': {},
        "createdAt": DateTime.now().toIso8601String(),
      },
    ).then((value) async {
      brRecepata++;
      setState(() {
        isLoading = false;
      });
      _storedImage = null;
      data['naziv'] = '';
      data['opis'] = '';
      data['brOsoba'] = 0;
      data['vrPripreme'] = 0;
      tezina = null;
      strTezina = null;
      sastojci.clear();
      koraci.clear();
      tagovi.clear();

      _form.currentState!.reset();

      sastojakFokus = [FocusNode()];
      sastojakInput = [TextEditingController()];
      korakFokus = [FocusNode()];
      korakInput = [TextEditingController()];

      // Navigator.pushReplacementNamed(context, BottomNavigationBarScreen.routeName);
    });
  }

  void submitForm() async {
    try {
      await InternetAddress.lookup('google.com');
    } catch (error) {
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
    if (tezina == null) {
      setState(() {
        tezinaValidator = true;
      });
      return;
    }
    if (tagovi.isEmpty) {
      setState(() {
        tagValidator = true;
        return;
      });
    }

    if (_storedImage == null) {
      setState(() {
        slikaValidator = 'Molimo Vas izaberite sliku';
      });
      return;
    }

    if (_storedImage!.readAsBytesSync().lengthInBytes / 1048576 >= 3.5) {
      setState(() {
        slikaValidator = 'Molimo Vas da izaberete drugu sliku';
      });
      return;
    }

    _form.currentState!.save();
    switch (tezina) {
      case Tezina.lako:
        strTezina = 'Lako';
        break;
      case Tezina.umjereno:
        strTezina = 'Umjereno';
        break;
      case Tezina.tesko:
        strTezina = 'Tesko';
        break;
      default:
    }
    try {
      setState(() {
        isLoading = true;
      });

      await FirebaseFirestore.instance.collection('recepti').add({
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'naziv': data['naziv'],
        'opis': data['opis'],
        'brOsoba': data['brOsoba'],
        'vrPripreme': data['vrPripreme'],
        'tezina': strTezina,
        'sastojci': sastojci,
        'koraci': koraci,
        'tagovi': tagovi,
        'favorites': {},
        'ratings': {},
        "createdAt": DateTime.now().toIso8601String(),
      }).then((value) async {
        final uploadedImage = await FirebaseStorage.instance.ref().child('receptImages').child('${value.id}.jpg').putFile(_storedImage!).then((value) async {
          value.ref.name;
          final imageUrl = await value.ref.getDownloadURL();
          await FirebaseFirestore.instance.collection('recepti').doc(value.ref.name.substring(0, value.ref.name.length - 4)).update({'imageUrl': imageUrl}).then((value) {
            setState(() {
              isLoading = false;
            });
            _storedImage = null;
            data['naziv'] = '';
            data['opis'] = '';
            data['brOsoba'] = 0;
            data['vrPripreme'] = 0;
            tezina = null;
            strTezina = null;
            sastojci.clear();
            koraci.clear();
            tagovi.clear();

            _form.currentState!.reset();

            sastojakFokus = [FocusNode()];
            sastojakInput = [TextEditingController()];
            korakFokus = [FocusNode()];
            korakInput = [TextEditingController()];

            Navigator.pushReplacementNamed(context, BottomNavigationBarScreen.routeName);
          });
        });
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });

      Metode.showErrorDialog(
        isJednoPoredDrugog: false,
        context: context,
        naslov: 'Došlo je do greške',
        button1Text: 'Zatvori',
        button1Fun: () {
          Navigator.pop(context);
        },
        isButton2: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);

    return SingleChildScrollView(
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Column(
          children: [
            SafeArea(
              child: Container(
                padding: EdgeInsets.only(top: (medijakveri.size.height - medijakveri.padding.top) * 0.035, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Dodaj',
                          style: Theme.of(context).textTheme.headline2,
                        ),
                      ],
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
                              nazivNode.unfocus();
                              opisNode.unfocus();
                              brOsobaNode.unfocus();
                              vrPripremeNode.unfocus();
                              sastojakFokus.forEach((element) {
                                element.unfocus();
                              });
                              korakFokus.forEach((element) {
                                element.unfocus();
                              });
                              submitForm();
                              // addMealTest();
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
            SizedBox(
              height: (medijakveri.size.height - medijakveri.padding.top) * 0.80,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Form(
                      key: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              width: medijakveri.size.width,
                              height: medijakveri.size.width * 0.48,
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
                                          width: medijakveri.size.width,
                                          height: medijakveri.size.width * 0.48,
                                        )
                                      : Text(
                                          'Dodajte sliku',
                                          style: Theme.of(context).textTheme.headline2,
                                        ),
                                ),
                              ),
                            ),
                          ),

                          if (slikaValidator != null)
                            Container(
                              margin: const EdgeInsets.only(left: 15, top: 10),
                              child: Text(
                                slikaValidator!,
                                style: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.red),
                              ),
                            ),
                          const SizedBox(height: 10),
                          if (_storedImage != null)
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
                                  });
                                },
                              ),
                            ),

                          //
                          //
                          // NAZIV
                          const SizedBox(height: 10),
                          InputField(
                            focusNode: nazivNode,
                            isMargin: false,
                            medijakveri: medijakveri,
                            isLabel: false,
                            hintText: 'Naziv recepta',
                            inputAction: TextInputAction.next,
                            inputType: TextInputType.text,
                            kapitulacija: TextCapitalization.sentences,
                            obscureText: false,
                            onChanged: (_) => _form.currentState!.validate(),
                            validator: (value) {
                              if (opisNode.hasFocus || brOsobaNode.hasFocus || vrPripremeNode.hasFocus) {
                                return null;
                              } else if (value!.trim().isEmpty || value == '') {
                                return 'Molimo Vas da unesete naziv recepta';
                              } else if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(value)) {
                                return 'Taj naziv nije validan';
                              } else if (value.length < 2) {
                                return 'Naziv recepta mora biti duži';
                              } else if (value.length > 45) {
                                return 'Naziv recepta mora biti kraći';
                              }
                            },
                            onSaved: (value) {
                              data['naziv'] = value!.trim();
                            },
                            borderRadijus: 10,
                          ),
                          const SizedBox(height: 15),
                          //
                          //
                          // OPIS
                          InputField(
                            focusNode: opisNode,
                            isMargin: false,
                            medijakveri: medijakveri,
                            isLabel: false,
                            hintText: 'Podijelite nešto više o ovom jelu',
                            inputAction: TextInputAction.next,
                            inputType: TextInputType.text,
                            obscureText: false,
                            kapitulacija: TextCapitalization.sentences,
                            borderRadijus: 10,
                            brMaxLinija: 4,
                            brMinLinija: 4,
                            onChanged: (_) => _form.currentState!.validate(),
                            validator: (value) {
                              if (nazivNode.hasFocus || brOsobaNode.hasFocus || vrPripremeNode.hasFocus) {
                                return null;
                              } else if (value!.trim().isEmpty) {
                                return 'Molimo Vas da unesete opis jela';
                              } else if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(value)) {
                                return 'Taj opis nije validan';
                              } else if (value.length < 2) {
                                return 'Opis jela mora biti duži';
                              } else if (value.length > 250) {
                                return 'Opis jela mora biti kraći';
                              }
                            },
                            onSaved: (value) {
                              data['opis'] = value!.trim();
                            },
                          ),
                          const SizedBox(height: 15),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //
                              //
                              // BROJ OSOBA
                              InputField(
                                focusNode: brOsobaNode,
                                isMargin: false,
                                medijakveri: medijakveri,
                                isLabel: false,
                                hintText: 'Broj osoba',
                                inputAction: TextInputAction.next,
                                inputType: TextInputType.number,
                                obscureText: false,
                                kapitulacija: TextCapitalization.sentences,
                                errorStyle: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.red),
                                onChanged: (_) => _form.currentState!.validate(),
                                textInputFormater: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                ],
                                validator: (value) {
                                  if (nazivNode.hasFocus || opisNode.hasFocus || vrPripremeNode.hasFocus) {
                                    return null;
                                  } else if (value!.isEmpty || value.trim().isEmpty) {
                                    return 'Molimo Vas da unesete polje';
                                  } else if (value.contains(',') || value.contains('.') || value.contains('-')) {
                                    return 'Polje smije sadržati samo brojeve';
                                  } else if (int.parse(value) > 20 || int.parse(value) < 1) {
                                    return 'Polje ne može biti veće od 20 ili manje od 1';
                                  }
                                },
                                onSaved: (value) {
                                  data['brOsoba'] = value!.trim();
                                },
                                borderRadijus: 10,
                                isFixedWidth: true,
                                // fixedWidth: 168,
                                fixedWidth: medijakveri.size.width * 0.41,
                              ),
                              //
                              //
                              // VRIJEME PRIPREME
                              InputField(
                                focusNode: vrPripremeNode,
                                isMargin: false,
                                medijakveri: medijakveri,
                                isLabel: false,
                                hintText: 'Vrijeme pripreme (MIN)',
                                inputAction: TextInputAction.next,
                                inputType: TextInputType.number,
                                obscureText: false,
                                kapitulacija: TextCapitalization.sentences,
                                hintTextSize: medijakveri.size.width * 0.035,
                                errorStyle: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.red),
                                onChanged: (_) => _form.currentState!.validate(),
                                textInputFormater: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                ],
                                validator: (value) {
                                  if (nazivNode.hasFocus || opisNode.hasFocus || brOsobaNode.hasFocus) {
                                    return null;
                                  } else if (value!.isEmpty || value.trim().isEmpty) {
                                    return 'Molimo Vas da unesete polje';
                                  } else if (value.contains(',') || value.contains('.') || value.contains('-')) {
                                    return 'Polje smije sadržati samo brojeve';
                                  } else if (int.parse(value) > 999 || int.parse(value) < 1) {
                                    return 'Polje ne može biti veće od 999 ili manje od 1';
                                  }
                                },
                                onSaved: (value) {
                                  data['vrPripreme'] = value!.trim();
                                },
                                borderRadijus: 10,
                                isFixedWidth: true,
                                fixedWidth: medijakveri.size.width * 0.41,
                              ),
                            ],
                          ),
                          //
                          //
                          // TEZINA
                          const SizedBox(height: 20),
                          Text(
                            'Težina',
                            style: Theme.of(context).textTheme.headline2,
                          ),
                          const SizedBox(height: 15),
                          Container(
                            width: medijakveri.size.width,
                            height: 40,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: tezinaValidator
                                    ? Border.all(
                                        color: Colors.red,
                                      )
                                    : null),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      tezina = Tezina.lako;
                                      tezinaValidator = false;
                                    });
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(tezina == Tezina.lako ? 'assets/icons/LakoSelected.svg' : 'assets/icons/LakoUnselected.svg'),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Lako',
                                          style: Theme.of(context).textTheme.headline5!.copyWith(
                                                color: tezina == Tezina.lako ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      tezina = Tezina.umjereno;
                                      tezinaValidator = false;
                                    });
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(tezina == Tezina.umjereno ? 'assets/icons/UmjerenoSelected.svg' : 'assets/icons/UmjerenoUnselected.svg'),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Umjereno',
                                          style: Theme.of(context).textTheme.headline5!.copyWith(
                                                color: tezina == Tezina.umjereno ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      tezina = Tezina.tesko;
                                      tezinaValidator = false;
                                    });
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(tezina == Tezina.tesko ? 'assets/icons/TeskoSelected.svg' : 'assets/icons/TeskoUnselected.svg'),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Teško',
                                          style: Theme.of(context).textTheme.headline5!.copyWith(
                                                color: tezina == Tezina.tesko ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (tezinaValidator)
                            Container(
                              margin: const EdgeInsets.only(left: 15, top: 10),
                              child: Text(
                                'Molimo Vas izaberite težinu',
                                style: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.red),
                              ),
                            ),
                          const SizedBox(height: 20),
                          //
                          //
                          //
                          // SASTOJCI
                          Text(
                            'Sastojci',
                            style: Theme.of(context).textTheme.headline2,
                          ),
                          const SizedBox(height: 15),
                          ListView.separated(
                            shrinkWrap: true,
                            primary: false,
                            padding: EdgeInsets.zero,
                            separatorBuilder: (context, index) => const SizedBox(height: 20),
                            itemCount: sastojakInput.length,
                            itemBuilder: (context, index) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InputField(
                                  isMargin: false,
                                  medijakveri: medijakveri,
                                  hintText: "Sastojak",
                                  inputAction: TextInputAction.next,
                                  inputType: TextInputType.text,
                                  sirina: 0.77,
                                  borderRadijus: 10,
                                  brMaxLinija: 2,
                                  controller: sastojakInput[index],
                                  focusNode: sastojakFokus[index],
                                  obscureText: false,
                                  kapitulacija: TextCapitalization.sentences,
                                  textInputFormater: <TextInputFormatter>[
                                    // FilteringTextInputFormatter.allow(RegExp(r'^[.,;\"()\[\]{}a-zA-Z0-9]*$')),
                                  ],
                                  onFieldSubmitted: (_) {
                                    if (index + 1 < sastojakFokus.length) {
                                      FocusScope.of(context).requestFocus(sastojakFokus[index + 1]);
                                    } else {
                                      FocusScope.of(context).requestFocus(korakFokus[0]);
                                    }
                                  },
                                  validator: (value) {
                                    if (nazivNode.hasFocus || opisNode.hasFocus || brOsobaNode.hasFocus || vrPripremeNode.hasFocus) {
                                      return null;
                                    } else if (value!.trim().isEmpty || value == '') {
                                      return 'Molimo Vas da unesete polje';
                                    } else if (!RegExp(r'^[.,;:!?\"()\[\]{}<>@#$%^&*_+=/\\|`~a-zA-Z0-9 ]*$').hasMatch(value)) {
                                      return 'Polje nije validno';
                                    } else if (value.length > 150) {
                                      return 'Polje mora biti kraće';
                                    }
                                  },
                                  onSaved: (value) {
                                    sastojci.add(value!.trim());
                                  },
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (index == 0) {
                                      return;
                                    }
                                    setState(() {
                                      sastojakInput[index].clear();
                                      sastojakInput[index].dispose();
                                      sastojakInput.removeAt(index);
                                    });
                                  },
                                  child: Icon(
                                    Iconsax.trash,
                                    color: index == 0 ? Colors.grey : Theme.of(context).colorScheme.primary,
                                    //
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (sastojakInput.length > 98) {
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Ne možete dodati više sastojaka.',
                                          style: Theme.of(context).textTheme.headline4,
                                        ),
                                        duration: const Duration(milliseconds: 900),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Theme.of(context).colorScheme.secondary,
                                        elevation: 4,
                                      ),
                                    );
                                    return;
                                  }

                                  sastojakInput.add(TextEditingController());
                                  sastojakFokus.add(FocusNode());
                                  sastojakFokus[sastojakFokus.length - 1].requestFocus();
                                });
                              },
                              child: Icon(
                                Iconsax.add_circle,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          //
                          //
                          //
                          // KORACI

                          const SizedBox(height: 20),
                          Text(
                            'Koraci',
                            style: Theme.of(context).textTheme.headline2,
                          ),
                          const SizedBox(height: 15),
                          ListView.separated(
                            shrinkWrap: true,
                            primary: false,
                            padding: EdgeInsets.zero,
                            separatorBuilder: (context, index) => const SizedBox(height: 20),
                            itemCount: korakInput.length,
                            itemBuilder: (context, index) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.tertiary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: Theme.of(context).textTheme.headline2?.copyWith(
                                            color: Colors.white,
                                          ),
                                    ),
                                  ),
                                ),
                                InputField(
                                  controller: korakInput[index],
                                  focusNode: korakFokus[index],
                                  brMaxLinija: 3,
                                  isMargin: false,
                                  medijakveri: medijakveri,
                                  hintText: "Korak",
                                  inputAction: TextInputAction.next,
                                  inputType: TextInputType.text,
                                  obscureText: false,
                                  kapitulacija: TextCapitalization.sentences,
                                  onFieldSubmitted: (_) {
                                    if (index + 1 < korakFokus.length) {
                                      FocusScope.of(context).requestFocus(korakFokus[index + 1]);
                                    } else {
                                      FocusScope.of(context).requestFocus(tagNode);
                                    }
                                  },
                                  validator: (value) {
                                    if (nazivNode.hasFocus || opisNode.hasFocus || brOsobaNode.hasFocus || vrPripremeNode.hasFocus) {
                                      return null;
                                    }
                                    if (value!.trim().isEmpty) {
                                      return 'Molimo Vas da unesete polje';
                                    } else if (value!.trim().isEmpty || value == '') {
                                      return 'Molimo Vas da unesete polje';
                                    } else if (!RegExp(r'^[.,;:!?\"()\[\]{}<>@#$%^&*_+=/\\|`~a-zA-Z0-9 ]*$').hasMatch(value)) {
                                      return 'Polje nije validno';
                                    } else if (value.length > 300) {
                                      return 'Polje mora biti kraće';
                                    }
                                  },
                                  onSaved: (value) {
                                    koraci.add(value!.trim());
                                  },
                                  sirina: 0.65,
                                  borderRadijus: 10,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (index == 0) {
                                      return;
                                    }
                                    setState(() {
                                      korakInput[index].clear();
                                      korakInput[index].dispose();
                                      korakInput.removeAt(index);
                                    });
                                  },
                                  child: Icon(
                                    Iconsax.trash,
                                    color: index == 0 ? Colors.grey : Theme.of(context).colorScheme.primary,
                                    //
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (korakInput.length > 98) {
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Ne možete dodati više koraka.',
                                          style: Theme.of(context).textTheme.headline4,
                                        ),
                                        duration: const Duration(milliseconds: 900),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Theme.of(context).colorScheme.secondary,
                                        elevation: 4,
                                      ),
                                    );
                                    return;
                                  }
                                  korakInput.add(TextEditingController());
                                  korakFokus.add(FocusNode());
                                  korakFokus[korakFokus.length - 1].requestFocus();
                                });
                              },
                              child: Icon(
                                Iconsax.add_circle,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          //
                          //
                          // TAGOVI

                          const SizedBox(height: 20),
                          Text(
                            'Tagovi',
                            style: Theme.of(context).textTheme.headline2,
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              if (tagovi.length == 5) {
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Ne možete dodati više od 5 tagova.',
                                      style: Theme.of(context).textTheme.headline4,
                                    ),
                                    duration: const Duration(milliseconds: 900),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Theme.of(context).colorScheme.secondary,
                                    elevation: 4,
                                  ),
                                );
                              }
                            },
                            child: MultipleSearchSelection<String>(
                              items: localAvailableTagovi,
                              fieldToCheck: (tag) {
                                return tag;
                              },
                              maxSelectedItems: 5,
                              textFieldFocus: tagNode,
                              clearSearchFieldOnSelect: true,
                              searchFieldTextStyle: Theme.of(context).textTheme.headline4,
                              itemsVisibility: ShowedItemsVisibility.alwaysOn,
                              showSelectAllButton: false,
                              pickedItemsContainerMinHeight: 40,
                              pickedItemsBoxDecoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              pickedItemBuilder: (tag) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.tertiary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "#$tag",
                                          style: Theme.of(context).textTheme.headline5!.copyWith(
                                                color: Colors.white,
                                              ),
                                        ),
                                        const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              clearAllButton: GestureDetector(
                                child: Text(
                                  'Obrišite sve',
                                  style: Theme.of(context).textTheme.headline4,
                                ),
                              ),
                              searchFieldBoxDecoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              showedItemsScrollbarColor: Colors.transparent,
                              searchFieldInputDecoration: InputDecoration(
                                hintText: "Potražite tag",
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                hintStyle: Theme.of(context).textTheme.headline4?.copyWith(
                                      color: Colors.grey,
                                    ),
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: tagValidator == true ? const BorderSide(color: Colors.red) : const BorderSide(color: Colors.transparent),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.transparent),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              itemBuilder: (tag, index) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                margin: const EdgeInsets.only(top: 10),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    bottom: BorderSide(color: Colors.black, width: 0.5),
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: Theme.of(context).textTheme.headline4,
                                ),
                              ),
                              onItemAdded: (itemName) {
                                tagovi.add(itemName);
                                setState(() {
                                  tagValidator = false;
                                });
                              },
                              onItemRemoved: (itemName) {
                                tagovi.removeWhere((elementName) => itemName == elementName);
                              },
                              onTapClearAll: () {
                                tagovi.clear();
                              },
                              showedItemsBoxDecoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              maximumShowItemsHeight: 200,
                              noResultsWidget: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    'Ne možemo da nađemo taj tag',
                                    style: Theme.of(context).textTheme.headline4,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          if (tagValidator)
                            Container(
                              margin: const EdgeInsets.only(left: 15, top: 10),
                              child: Text(
                                'Molimo Vas izaberite bar jedan tag',
                                style: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.red),
                              ),
                            ),
                          // SizedBox(height: widget.tastaturaHeight!),
                          const SizedBox(height: 60),
                        ],
                      ),
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

  @override
  void dispose() {
    super.dispose();
    nazivNode.dispose();
    opisNode.dispose();
    brOsobaNode.dispose();
    vrPripremeNode.dispose();
    tagNode.dispose();
  }
}
