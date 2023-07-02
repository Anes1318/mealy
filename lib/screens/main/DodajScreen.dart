import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealy/components/Button.dart';
import 'package:mealy/components/metode.dart';
import 'package:multiple_search_selection/multiple_search_selection.dart';
// komponente
import 'package:mealy/components/InputField.dart';
import '../../models/tezina.dart';

class DodajScreen extends StatefulWidget {
  static const String routeName = '/DodajScreen';

  const DodajScreen({super.key});

  @override
  State<DodajScreen> createState() => _DodajScreenState();
}

class _DodajScreenState extends State<DodajScreen> with SingleTickerProviderStateMixin {
  final _form = GlobalKey<FormState>();

  final imeNode = FocusNode();
  final opisNode = FocusNode();
  final brOsobaNode = FocusNode();
  final vrPripremeNode = FocusNode();
  final tagNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    imeNode.dispose();
    opisNode.dispose();
    brOsobaNode.dispose();
    vrPripremeNode.dispose();
    tagNode.dispose();
  }

  List<String> availableTagovi = [
    "Doručak",
    "Ručak",
    "Večera",
    "Zdravo",
    "Brza hrana",
    "Pite",
    "Salate",
    "A3",
    "A4",
    "A5",
  ];

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
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
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
    'ime': '',
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
  void submitForm() async {
    try {
      final internetTest = await InternetAddress.lookup('google.com');
    } catch (error) {
      Metode.showErrorDialog(
        message: "Došlo je do greške sa internetom. Proverite svoju konekciju.",
        context: context,
        naslov: 'Greška',
        button1Text: 'Zatvori',
        button1Fun: () => {Navigator.pop(context)},
        isButton2: false,
      );
      return;
    }

    if (tezina == null) {
      setState(() {
        tezinaValidator = true;
        return;
      });
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

      await FirebaseFirestore.instance.collection('recepti').add({
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'recept': {
          'ime': data['ime'],
          'opis': data['opis'],
          'brOsoba': data['brOsoba'],
          'vrPripreme': data['vrPripreme'],
          'tezina': strTezina,
          'sastojci': sastojci,
          'koraci': koraci,
          'tagovi': tagovi,
        }
      }).then((value) async {
        final uploadedImage = await FirebaseStorage.instance.ref().child('receptImages').child('${value.id}.jpg').putFile(_storedImage!).then((value) async {
          value.ref.name;
          final imageUrl = await value.ref.getDownloadURL();
          await FirebaseFirestore.instance.collection('recepti').doc(value.ref.name.substring(0, value.ref.name.length - 4)).update({'imageUrl': imageUrl}).then((value) {
            setState(() {
              isLoading = false;
            });
            _storedImage = null;
            data['ime'] = '';
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
          });
        });
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      Metode.showErrorDialog(
        context: context,
        naslov: 'Došlo je do greške',
        button1Text: 'Ok',
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

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: (medijakveri.size.height - medijakveri.padding.top) * 0.07),
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
                      ? const SizedBox(
                          height: 34,
                          width: 34,
                          child: CircularProgressIndicator(),
                        )
                      : InkWell(
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
            const SizedBox(height: 25),
            SizedBox(
              height: (medijakveri.size.height - medijakveri.padding.top) * 0.779,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Form(
                      key: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
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
                              height: 195,
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
                                          fit: BoxFit.cover,
                                          width: double.infinity,
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
                                color: Theme.of(context).colorScheme.tertiary,
                                isBorder: false,
                                funkcija: () {
                                  setState(() {
                                    _storedImage = null;
                                  });
                                },
                              ),
                            ),

                          const SizedBox(height: 10),
                          InputField(
                            focusNode: imeNode,
                            isMargin: false,
                            medijakveri: medijakveri,
                            isLabel: false,
                            hintText: 'Ime jela',
                            inputAction: TextInputAction.next,
                            inputType: TextInputType.text,
                            obscureText: false,
                            onChanged: (_) => _form.currentState!.validate(),
                            validator: (value) {
                              if (opisNode.hasFocus || brOsobaNode.hasFocus || vrPripremeNode.hasFocus) {
                                return null;
                              } else if (value!.isEmpty || value.trim().isEmpty) {
                                return 'Molimo Vas da unesete ime jela';
                              } else if (value.length < 2) {
                                return 'Ime jela mora biti duže';
                              } else if (value.contains(RegExp(r'[0-9]'))) {
                                return 'Ime jela smije sadržati samo velika i mala slova i simbole';
                              }
                            },
                            onSaved: (value) {
                              data['ime'] = value!.trim();
                            },
                            borderRadijus: 10,
                          ),
                          const SizedBox(height: 20),
                          InputField(
                            focusNode: opisNode,
                            isMargin: false,
                            medijakveri: medijakveri,
                            isLabel: false,
                            hintText: 'Podijelite nešto više o ovom jelu',
                            inputAction: TextInputAction.next,
                            inputType: TextInputType.text,
                            obscureText: false,
                            onChanged: (_) => _form.currentState!.validate(),
                            validator: (value) {
                              if (imeNode.hasFocus || brOsobaNode.hasFocus || vrPripremeNode.hasFocus) {
                                return null;
                              } else if (value!.isEmpty || value.trim().isEmpty) {
                                return 'Molimo Vas da unesete opis jela';
                              } else if (value.length < 2) {
                                return 'Opis jela mora biti duži';
                              }
                            },
                            onSaved: (value) {
                              data['opis'] = value!.trim();
                            },
                            borderRadijus: 10,
                            brLinija: 4,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InputField(
                                focusNode: brOsobaNode,
                                isMargin: false,
                                medijakveri: medijakveri,
                                isLabel: false,
                                hintText: 'Broj osoba',
                                inputAction: TextInputAction.next,
                                inputType: TextInputType.number,
                                obscureText: false,
                                errorStyle: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.red),
                                onChanged: (_) => _form.currentState!.validate(),
                                validator: (value) {
                                  if (imeNode.hasFocus || opisNode.hasFocus || vrPripremeNode.hasFocus) {
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
                                focusNode: vrPripremeNode,
                                isMargin: false,
                                medijakveri: medijakveri,
                                isLabel: false,
                                hintText: 'Vrijeme pripreme (min)',
                                inputAction: TextInputAction.next,
                                inputType: TextInputType.number,
                                obscureText: false,
                                hintTextSize: 14,
                                errorStyle: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.red),
                                onChanged: (_) => _form.currentState!.validate(),
                                validator: (value) {
                                  if (imeNode.hasFocus || opisNode.hasFocus || brOsobaNode.hasFocus) {
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
                            style: Theme.of(context).textTheme.headline4,
                          ),
                          const SizedBox(height: 10),
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
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      tezina = Tezina.lako;
                                      tezinaValidator = false;
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
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      tezina = Tezina.umjereno;
                                      tezinaValidator = false;
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
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      tezina = Tezina.tesko;
                                      tezinaValidator = false;
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
                          ListView.separated(
                            shrinkWrap: true,
                            primary: false,
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
                                  onFieldSubmitted: (_) {
                                    if (index + 1 < sastojakFokus.length) {
                                      FocusScope.of(context).requestFocus(sastojakFokus[index + 1]);
                                    } else {
                                      FocusScope.of(context).requestFocus(korakFokus[0]);
                                    }
                                  },
                                  validator: (value) {
                                    if (imeNode.hasFocus || opisNode.hasFocus || brOsobaNode.hasFocus || vrPripremeNode.hasFocus) {
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
                                InkWell(
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
                            child: InkWell(
                              onTap: () {
                                setState(() {
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
                          const SizedBox(height: 15),
                          Text(
                            'Koraci',
                            style: Theme.of(context).textTheme.headline2,
                          ),
                          ListView.separated(
                            shrinkWrap: true,
                            primary: false,
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
                                  isMargin: false,
                                  medijakveri: medijakveri,
                                  hintText: "Korak",
                                  inputAction: TextInputAction.next,
                                  inputType: TextInputType.text,
                                  obscureText: false,
                                  onFieldSubmitted: (_) {
                                    if (index + 1 < korakFokus.length) {
                                      FocusScope.of(context).requestFocus(korakFokus[index + 1]);
                                    } else {
                                      FocusScope.of(context).requestFocus(tagNode);
                                    }
                                  },
                                  validator: (value) {
                                    if (imeNode.hasFocus || opisNode.hasFocus || brOsobaNode.hasFocus || vrPripremeNode.hasFocus) {
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
                                  controller: korakInput[index],
                                  focusNode: korakFokus[index],
                                ),
                                InkWell(
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
                            child: InkWell(
                              onTap: () {
                                setState(() {
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
                          // TODO: napravi da se tagovi brisu (ui) nakon dodanog recepta
                          const SizedBox(height: 15),
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
                              items: availableTagovi,
                              fieldToCheck: (tag) {
                                return tag;
                              },
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
                              clearAllButton: Text(
                                'Obrišite sve',
                                style: Theme.of(context).textTheme.headline4,
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
                                  borderSide: const BorderSide(color: Colors.white),
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
                                  padding: EdgeInsets.all(10),
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
                          const SizedBox(height: 30),
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
}
