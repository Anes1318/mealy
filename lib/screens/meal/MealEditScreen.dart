import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multiple_search_selection/multiple_search_selection.dart';

import '../../components/InputField.dart';
import '../../components/metode.dart';
import '../../models/availableTagovi.dart';
import '../../models/tezina.dart';
import '../main/BottomNavigationBarScreen.dart';

class MealEditScreen extends StatefulWidget {
  static const String routeName = '/ReceptEditScreen';

  final String autorId;
  final String receptId;
  final String naziv;
  final String opis;
  final String brOsoba;
  final String vrPripreme;
  final String tezina;
  final String imageUrl;
  final Map<String, dynamic> ratings;
  final List<dynamic> sastojci;
  final List<dynamic> koraci;
  final List<dynamic> favorites;
  final List<dynamic> tagovi;

  MealEditScreen({
    required this.autorId,
    required this.receptId,
    required this.naziv,
    required this.opis,
    required this.brOsoba,
    required this.vrPripreme,
    required this.tezina,
    required this.imageUrl,
    required this.ratings,
    required this.sastojci,
    required this.koraci,
    required this.favorites,
    required this.tagovi,
  });

  @override
  State<MealEditScreen> createState() => _MealEditScreenState();
}

class _MealEditScreenState extends State<MealEditScreen> {
  final _form = GlobalKey<FormState>();

  final nazivNode = FocusNode();
  final opisNode = FocusNode();
  final brOsobaNode = FocusNode();
  final vrPripremeNode = FocusNode();
  final tagNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    nazivNode.dispose();
    opisNode.dispose();
    brOsobaNode.dispose();
    vrPripremeNode.dispose();
    tagNode.dispose();
  }

  List<String> localAvailableTagovi = availableTagovi;

  List<TextEditingController> sastojakInput = [];
  List<FocusNode> sastojakFokus = [];
  List<TextEditingController> korakInput = [];
  List<FocusNode> korakFokus = [];

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

  bool tagValidator = false;
  String? slikaValidator;

  void submitForm() async {
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

    if (tagovi.isEmpty) {
      setState(() {
        tagValidator = true;
        return;
      });
    }
    if (_storedImage != null) {
      if (_storedImage!.readAsBytesSync().lengthInBytes / 1048576 >= 3.5) {
        setState(() {
          slikaValidator = 'Molimo Vas da izaberete drugu sliku';
        });
        return;
      }
    }

    if (!_form.currentState!.validate()) {
      return;
    }
    _form.currentState!.save();

    try {
      setState(() {
        isLoading = true;
      });
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

      await FirebaseFirestore.instance.collection('recepti').doc(widget.receptId).set(
        {
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'favorites': widget.favorites,
          'naziv': data['naziv'],
          'opis': data['opis'],
          'brOsoba': data['brOsoba'],
          'vrPripreme': data['vrPripreme'],
          'tezina': strTezina,
          'sastojci': sastojci,
          'koraci': koraci,
          'tagovi': tagovi,
          'ratings': widget.ratings,
          'imageUrl': widget.imageUrl,
        },
      ).then((value) async {
        if (_storedImage != null) {
          await FirebaseStorage.instance.ref().child(widget.receptId).delete();
          final uploadedImage = await FirebaseStorage.instance.ref().child('receptImages').child('${widget.receptId}.jpg').putFile(_storedImage!).then((value) async {
            value.ref.name;
            final imageUrl = await value.ref.getDownloadURL();
            await FirebaseFirestore.instance.collection('recepti').doc(value.ref.name.substring(0, value.ref.name.length - 4)).update({'imageUrl': imageUrl}).then((value) {});
          });
        }
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
    } catch (error) {
      setState(() {
        isLoading = false;
      });

      Metode.showErrorDialog(
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
  void initState() {
    super.initState();
    data['naziv'] = widget.naziv;
    data['opis'] = widget.opis;
    data['brOsoba'] = widget.brOsoba;
    data['vrPripreme'] = widget.vrPripreme;

    widget.tagovi.forEach((element) {
      tagovi.add(element);
    });
    tagovi.forEach((element) {
      localAvailableTagovi.remove(element);
    });
    for (var i = 0; i < widget.sastojci.length; i++) {
      sastojakInput.add(TextEditingController(text: widget.sastojci[i]));
      sastojakFokus.add(FocusNode());
    }
    for (var i = 0; i < widget.koraci.length; i++) {
      korakInput.add(TextEditingController(text: widget.koraci[i]));
      korakFokus.add(FocusNode());
    }
    switch (widget.tezina) {
      case 'Lako':
        tezina = Tezina.lako;
        break;
      case 'Umjereno':
        tezina = Tezina.umjereno;
        break;
      case 'Tesko':
        tezina = Tezina.tesko;
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: medijakveri.size.width * 0.07),
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
                              'Izmijenite recept',
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
                                  submitForm();
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
                  height: (medijakveri.size.height - medijakveri.padding.top) * 0.91,
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
                                    context: context,
                                    naslov: 'Odakle želite da izaberete sliku?',
                                    button1Text: 'Kamera',
                                    button1Fun: () {
                                      _takeImage(true);
                                      Navigator.pop(context);
                                    },
                                    isButton2: true,
                                    button2Text: 'Galerija',
                                    button2Fun: () {
                                      _takeImage(false);

                                      Navigator.pop(context);
                                    },
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
                                          : Image.network(
                                              widget.imageUrl,
                                              fit: BoxFit.fill,
                                            ),
                                    ),
                                  ),
                                ),
                              ),

                              // if (slikaValidator != null)
                              //   Container(
                              //     margin: const EdgeInsets.only(left: 15, top: 10),
                              //     child: Text(
                              //       slikaValidator!,
                              //       style: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.red),
                              //     ),
                              //   ),
                              // const SizedBox(height: 10),
                              // if (_storedImage != null)
                              //   Center(
                              //     child: Button(
                              //       isFullWidth: false,
                              //       buttonText: 'Uklonite sliku',
                              //       borderRadius: 5,
                              //       visina: 5,
                              //       sirina: 10,
                              //       fontsize: 16,
                              //       color: Theme.of(context).colorScheme.tertiary,
                              //       isBorder: false,
                              //       funkcija: () {
                              //         setState(() {
                              //           _storedImage = null;
                              //         });
                              //       },
                              //     ),
                              //   ),

                              const SizedBox(height: 20),
                              InputField(
                                initalValue: widget.naziv,
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
                                  } else if (value!.isEmpty || value.trim().isEmpty) {
                                    return 'Molimo Vas da unesete naziv recepta';
                                  } else if (value.length < 2) {
                                    return 'Naziv recepta mora biti duži';
                                  } else if (value.length > 45) {
                                    return 'Naziv recepta mora biti kraći';
                                  } else if (value.contains(RegExp(r'[0-9]'))) {
                                    return 'Naziv recepta smije sadržati samo velika i mala slova, i simbole';
                                  }
                                },
                                onSaved: (value) {
                                  data['naziv'] = value!.trim();
                                },
                                borderRadijus: 10,
                              ),
                              const SizedBox(height: 15),
                              InputField(
                                initalValue: widget.opis,
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
                                  } else if (value!.isEmpty || value.trim().isEmpty) {
                                    return 'Molimo Vas da unesete opis jela';
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
                                  InputField(
                                    initalValue: widget.brOsoba,
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
                                    validator: (value) {
                                      if (nazivNode.hasFocus || opisNode.hasFocus || vrPripremeNode.hasFocus) {
                                        return null;
                                      } else if (value!.isEmpty || value.trim().isEmpty) {
                                        return 'Molimo Vas da unesete polje';
                                      } else if (int.parse(value) > 20 || int.parse(value) < 1) {
                                        return 'Polje ne može biti veće od 20 ili manje od 1';
                                      }
                                    },
                                    onSaved: (value) {
                                      data['brOsoba'] = value!.trim();
                                    },
                                    borderRadijus: 10,
                                    sirina: 0.4,
                                  ),
                                  InputField(
                                    initalValue: widget.vrPripreme,
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
                                    validator: (value) {
                                      if (nazivNode.hasFocus || opisNode.hasFocus || brOsobaNode.hasFocus) {
                                        return null;
                                      } else if (value!.isEmpty || value.trim().isEmpty) {
                                        return 'Molimo Vas da unesete polje';
                                      } else if (int.parse(value) > 999 || int.parse(value) < 1) {
                                        return 'Polje ne može biti veće od 999 ili manje od 1';
                                      }
                                    },
                                    onSaved: (value) {
                                      data['vrPripreme'] = value!.trim();
                                    },
                                    borderRadijus: 10,
                                    sirina: 0.4,
                                  ),
                                ],
                              ),
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
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          tezina = Tezina.lako;
                                        });
                                      },
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
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          tezina = Tezina.umjereno;
                                        });
                                      },
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
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          tezina = Tezina.tesko;
                                        });
                                      },
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
                                  ],
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
                              SizedBox(height: 15),
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
                                      controller: sastojakInput[index],
                                      focusNode: sastojakFokus[index],
                                      obscureText: false,
                                      kapitulacija: TextCapitalization.sentences,
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
                                        }

                                        if (value!.trim().isEmpty) {
                                          return 'Molimo Vas da unesete polje';
                                        }
                                      },
                                      onSaved: (value) {
                                        sastojci.add(value!);
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
                                        }
                                      },
                                      onSaved: (value) {
                                        koraci.add(value!);
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
                                  initialPickedItems: tagovi,
                                  maxSelectedItems: 5,
                                  textFieldFocus: tagNode,
                                  clearSearchFieldOnSelect: true,
                                  searchFieldTextStyle: Theme.of(context).textTheme.headline4,
                                  itemsVisibility: ShowedItemsVisibility.onType,
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
                                    hintText: "Upišite tag",
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
                                    margin: const EdgeInsets.symmetric(vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: null,
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
                                  showedItemsBoxDecoration: const BoxDecoration(
                                    color: Color(0xFFFFEEEE),
                                  ),
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
        ),
      ),
    );
  }
}
