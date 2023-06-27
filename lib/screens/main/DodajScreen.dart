import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mealy/components/InputField.dart';
import 'package:mealy/models/tag.dart';
import 'package:multiple_search_selection/multiple_search_selection.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';

import '../../components/CustomAppbar.dart';

class DodajScreen extends StatefulWidget {
  static const String routeName = '/DodajScreen';

  const DodajScreen({super.key});

  @override
  State<DodajScreen> createState() => _DodajScreenState();
}

enum Tezina {
  lako,
  umjereno,
  tesko,
}

class _DodajScreenState extends State<DodajScreen> {
  final tagNode = FocusNode();

  @override
  void initState() {
    super.initState();
    tagNode.addListener(() {
      setState(() {});
    });
  }

  final _form = GlobalKey<FormState>();
  List<Tag> tagovi = [
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

  List<TextEditingController> sastojakInputList = [TextEditingController()];
  List<TextEditingController> korakInputList = [TextEditingController()];

  @override
  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);

    return SingleChildScrollView(
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
                          child: Container(
                            width: medijakveri.size.width,
                            height: 195,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                'Dodajte sliku',
                                style: Theme.of(context).textTheme.headline2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        InputField(
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
                          separatorBuilder: (context, index) => const SizedBox(height: 20),
                          itemCount: sastojakInputList.length,
                          itemBuilder: (context, index) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InputField(
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

                        InkWell(
                          onTap: () {
                            setState(() {
                              sastojakInputList.add(TextEditingController());
                            });
                          },
                          child: Center(
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
                        InkWell(
                          onTap: () {
                            setState(() {
                              korakInputList.add(TextEditingController());
                            });
                          },
                          child: Center(
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
                        SizedBox(height: 10),
                        MultipleSearchSelection<Tag>(
                          items: tagovi,
                          fieldToCheck: (tag) {
                            return tag.name;
                          },
                          maxSelectedItems: 5,
                          textFieldFocus: tagNode,
                          clearSearchFieldOnSelect: false,
                          searchFieldTextStyle: Theme.of(context).textTheme.headline4,
                          itemsVisibility: ShowedItemsVisibility.onType,
                          showSelectAllButton: false,
                          pickedItemsBoxDecoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          pickedItemsContainerMinHeight: 40,
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
                          searchFieldBoxDecoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            // border: Border.all(
                            //   color: Colors.black,
                            // ),
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
                              // border: Border.all(
                              //     // color: Colors.black.withOpacity(.5),
                              //     ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: null,
                            ),
                            child: Text(tag.name),
                          ),
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
                          clearAllButton: InkWell(
                            onTap: () {},
                            child: Text(
                              'Obrišite sve',
                              style: Theme.of(context).textTheme.headline4,
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
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tagNode.dispose();
  }
}
