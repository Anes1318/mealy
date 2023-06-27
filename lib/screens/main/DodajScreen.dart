import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mealy/components/InputField.dart';

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
  final _form = GlobalKey<FormState>();

  Tezina? tezina;

  List<TextEditingController> sastojakInputList = [TextEditingController()];
  List<TextEditingController> korakInputList = [TextEditingController()];

  @override
  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            child: CustomAppBar(
              pageTitle: 'Dodaj',
              isCenter: false,
              drugaIkonica: Iconsax.tick_circle,
              funkcija2: () {},
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
}
