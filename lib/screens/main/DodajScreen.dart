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
import 'package:mealy/models/tag.dart';
import '../../components/CustomAppbar.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imeNode.addListener(() {});
  }

  @override
  void dispose() {
    super.dispose();
    imeNode.dispose();
    opisNode.dispose();
    brOsobaNode.dispose();
    vrPripremeNode.dispose();
  }

  List<Tag> availableTagovi = [
    Tag(name: "Doručak"),
    Tag(name: "Ručak"),
    Tag(name: "Večera"),
    Tag(name: "Zdravo"),
    Tag(name: "Brza hrana"),
    Tag(name: "A1"),
    Tag(name: "A2"),
    Tag(name: "A3"),
    Tag(name: "A4"),
    Tag(name: "A5"),
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
    var croppedImg = await ImageCropper().cropImage(
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
      slikaValidator = false;
    });
  }

  Map<String, dynamic> data = {
    'ime': '',
    'opis': '',
    'brOsoba': 0,
    'vrPripreme': 0,
  };
  List<String> sastojci = [];
  List<String> koraci = [];
  List<String> niz = [
    'anes1',
    'anes2',
    'anes3',
    'anes4',
  ];
  Tezina? tezina;
  List<Tag> tagovi = [];
  bool tezinaValidator = false;
  bool tagValidator = false;
  bool slikaValidator = false;
  void submitForm() {
    if (tezina == null) {
      setState(() {
        tezinaValidator = true;
      });
    }
    if (tagovi.isEmpty) {
      setState(() {
        tagValidator = true;
      });
    }
    if (_storedImage == null) {
      setState(() {
        slikaValidator = true;
      });
    }

    if (!_form.currentState!.validate()) {
      return;
    }
    _form.currentState!.save();

    FirebaseStorage.instance.ref().child('receptImages').child(DateTime.now().toIso8601String()).putFile(_storedImage!);
    // try {
    //   FirebaseFirestore.instance.collection('recepti').add({
    //     'userId' : FirebaseAuth.instance.currentUser!.uid,
    //     'recept' : {
    //       'ime'
    //     }
    //   });
    // } catch (error) {}
    // print('ime : ${data['ime']}');
    // print('opis : ${data['opis']}');
    // print('brOsoba : ${data['brOsoba']}');
    // print('vrPripreme: ${data['vrPripreme']}');
    // print('tezina: $tezina');
    // sastojci.forEach((element) {
    //   print(element);
    // });
    // koraci.forEach((element) {
    //   print(element);
    // });
    // tagovi.forEach((element) {
    //   print(element);
    // });
  }

  @override
  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            CustomAppBar(
              pageTitle: 'Dodaj',
              isCenter: false,
              drugaIkonica: Iconsax.tick_circle,
              funkcija2: () {
                FocusManager.instance.primaryFocus?.unfocus();
                submitForm();
              },
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

                          if (slikaValidator)
                            Container(
                              margin: const EdgeInsets.only(left: 15, top: 10),
                              child: Text(
                                'Molimo Vas izaberite sliku',
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
                                  } else if (int.parse(value) > 20) {
                                    return 'Polje ne može biti veće od 20';
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
                                  } else if (int.parse(value) > 999) {
                                    return 'Polje ne može biti veće od 999';
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
                                  obscureText: false,
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
                                  sirina: 0.77,
                                  borderRadijus: 10,
                                  controller: sastojakInput[index],
                                  focusNode: sastojakFokus[index],
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
                            child: MultipleSearchSelection<Tag>(
                              items: availableTagovi,
                              fieldToCheck: (tag) {
                                return tag.name;
                              },
                              maxSelectedItems: 5,
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
                                          "#${tag.name}",
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
                                  borderSide: const BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              itemBuilder: (tag, index) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: null,
                                ),
                                child: Text(
                                  tag.name,
                                  style: Theme.of(context).textTheme.headline4,
                                ),
                              ),
                              onItemAdded: (item) {
                                tagovi.add(Tag(name: item.name));
                                setState(() {
                                  tagValidator = false;
                                });
                              },
                              onItemRemoved: (item) {
                                tagovi.removeWhere((element) => element.name == item.name);
                              },
                              onTapClearAll: () {
                                tagovi.clear();
                              },
                              showedItemsBoxDecoration: const BoxDecoration(
                                color: Color(0xFFFFEEEE),
                              ),
                              noResultsWidget: Container(
                                color: Colors.white,
                                padding: const EdgeInsets.all(15),
                                child: Text(
                                  'Ne možemo da nađemo taj tag',
                                  style: Theme.of(context).textTheme.headline4,
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

                          const SizedBox(height: 20),
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
