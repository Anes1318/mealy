import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealy/components/Button.dart';
import 'package:multiple_search_selection/multiple_search_selection.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;
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
  Tezina? tezina;
  List<Tag> tagovi = [];
  List<TextEditingController> sastojakInputList = [TextEditingController()];
  List<TextEditingController> korakInputList = [TextEditingController()];

  File? _pickedImage;
  void _selectImage(File pickedImage) {
    _pickedImage = pickedImage;
  }

  File? _storedImage;
  Future<void> _takeImage() async {
    final ImagePicker picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );
    setState(() {
      _storedImage = File(imageFile!.path);
    });
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(_storedImage!.path);
    final savedImage = await _storedImage!.copy('${appDir.path}/$fileName');
    _pickedImage = savedImage;
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
              funkcija2: () {},
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
                            onTap: () => _takeImage(),
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
                            isPadding: false,
                            medijakveri: medijakveri,
                            isLabel: false,
                            hintText: 'Ime jela',
                            inputAction: TextInputAction.next,
                            inputType: TextInputType.text,
                            obscureText: false,
                            validator: (value) {},
                            onSaved: (_) {},
                            borderRadijus: 10,
                          ),
                          const SizedBox(height: 20),
                          InputField(
                            isPadding: false,
                            medijakveri: medijakveri,
                            isLabel: false,
                            hintText: 'Podijelite nešto više o ovom jelu',
                            inputAction: TextInputAction.next,
                            inputType: TextInputType.text,
                            obscureText: false,
                            validator: (value) {},
                            onSaved: (_) {},
                            borderRadijus: 10,
                            brLinija: 4,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InputField(
                                isPadding: false,
                                medijakveri: medijakveri,
                                isLabel: false,
                                hintText: 'Za koliko osoba',
                                inputAction: TextInputAction.next,
                                inputType: TextInputType.text,
                                obscureText: false,
                                validator: (value) {},
                                onSaved: (_) {},
                                borderRadijus: 10,
                                sirina: 0.4,
                              ),
                              InputField(
                                isPadding: false,
                                medijakveri: medijakveri,
                                isLabel: false,
                                hintText: 'Vrijeme pripreme',
                                inputAction: TextInputAction.next,
                                inputType: TextInputType.text,
                                obscureText: false,
                                validator: (value) {},
                                onSaved: (_) {},
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
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                InkWell(
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
                                InkWell(
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
                                InkWell(
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
                          ListView.separated(
                            shrinkWrap: true,
                            primary: false,
                            separatorBuilder: (context, index) => const SizedBox(height: 20),
                            itemCount: sastojakInputList.length,
                            itemBuilder: (context, index) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InputField(
                                  isPadding: false,
                                  medijakveri: medijakveri,
                                  hintText: "Sastojak",
                                  inputAction: TextInputAction.next,
                                  inputType: TextInputType.text,
                                  obscureText: false,
                                  validator: (value) {},
                                  onSaved: (_) {},
                                  sirina: 0.77,
                                  borderRadijus: 10,
                                  controller: sastojakInputList[index],
                                ),
                                InkWell(
                                  onTap: () {
                                    if (index == 0) {
                                      return;
                                    }
                                    setState(() {
                                      sastojakInputList[index].clear();
                                      sastojakInputList[index].dispose();
                                      sastojakInputList.removeAt(index);
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
                                  sastojakInputList.add(TextEditingController());
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
                            itemCount: korakInputList.length,
                            itemBuilder: (context, index) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  // padding: EdgeInsets.all(15),
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
                                  isPadding: false,
                                  medijakveri: medijakveri,
                                  hintText: "Korak",
                                  inputAction: TextInputAction.next,
                                  inputType: TextInputType.text,
                                  obscureText: false,
                                  validator: (value) {},
                                  onSaved: (_) {},
                                  sirina: 0.65,
                                  borderRadijus: 10,
                                  controller: korakInputList[index],
                                ),
                                InkWell(
                                  onTap: () {
                                    if (index == 0) {
                                      return;
                                    }
                                    setState(() {
                                      korakInputList[index].clear();
                                      korakInputList[index].dispose();
                                      korakInputList.removeAt(index);
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
                                  korakInputList.add(TextEditingController());
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
                              clearSearchFieldOnSelect: false,
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
                              clearAllButton: InkWell(
                                onTap: () {},
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
                                child: Text(tag.name),
                              ),
                              onItemAdded: (item) {
                                tagovi.add(
                                  Tag(name: item.name),
                                );
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
