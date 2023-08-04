import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:iconsax/iconsax.dart';
import 'package:mealy/components/Button.dart';
import 'package:mealy/components/CustomAppbar.dart';
import 'package:mealy/components/InputField.dart';
import 'package:mealy/components/MealCard.dart';
import 'package:multiple_search_selection/multiple_search_selection.dart';
import 'package:provider/provider.dart';

import '../../components/metode.dart';
import '../../models/availableTagovi.dart';
import '../../models/tezina.dart';
import '../../providers/MealProvider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final form = GlobalKey<FormState>();

  Stream<QuerySnapshot<Map<String, dynamic>>>? meals;

  List<String> localAvailableTagovi = availableTagovi;

  bool? isInternet;
  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    Provider.of<MealProvider>(context).readMeals();
    meals = Provider.of<MealProvider>(context).meals;
    isInternet = Provider.of<MealProvider>(context).getIsInternet;
  }

  @override
  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            CustomAppBar(pageTitle: 'Početna', isCenter: false),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  child: Container(
                    width: medijakveri.size.width * 0.7,
                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        hintText: 'Potražite tag ili namirnicu...',
                        hintStyle: Theme.of(context).textTheme.headline4?.copyWith(
                              color: Colors.grey,
                            ),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        suffixIcon: const Icon(Iconsax.search_normal),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isDismissible: true,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      builder: (context) => Container(
                        padding: EdgeInsets.only(left: medijakveri.size.width * 0.07, right: medijakveri.size.width * 0.07, top: 20),
                        height: (medijakveri.size.height - medijakveri.padding.top) * 0.8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: Icon(
                                    Iconsax.filter_remove,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 30,
                                  ),
                                ),
                                Text(
                                  'Filteri',
                                  style: Theme.of(context).textTheme.headline2,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Icon(
                                    Iconsax.close_square,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 30,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Form(
                              key: form,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Broj osoba',
                                            style: Theme.of(context).textTheme.headline3,
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              InputField(
                                                medijakveri: medijakveri,
                                                hintText: 'Od',
                                                inputAction: TextInputAction.next,
                                                inputType: TextInputType.number,
                                                obscureText: false,
                                                validator: (value) {},
                                                onSaved: (value) {},
                                                isMargin: false,
                                                isFixedWidth: true,
                                                fixedWidth: 80,
                                                isLabel: false,
                                                borderRadijus: 10,
                                              ),
                                              const SizedBox(width: 10),
                                              InputField(
                                                medijakveri: medijakveri,
                                                hintText: 'Do',
                                                inputAction: TextInputAction.next,
                                                inputType: TextInputType.number,
                                                obscureText: false,
                                                validator: (value) {},
                                                onSaved: (value) {},
                                                isMargin: false,
                                                isFixedWidth: true,
                                                fixedWidth: 80,
                                                isLabel: false,
                                                borderRadijus: 10,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Težina',
                                            style: Theme.of(context).textTheme.headline3,
                                          ),
                                          const SizedBox(height: 10),
                                          Container(
                                            width: medijakveri.size.width - medijakveri.size.width * 0.14,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                              // border: tezinaValidator
                                              //     ? Border.all(
                                              //         color: Colors.red,
                                              //       )
                                              //     : null,
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      // tezina = Tezina.lako;
                                                      // tezinaValidator = false;
                                                    });
                                                  },
                                                  child: Row(
                                                    children: [
                                                      // SvgPicture.asset(tezina == Tezina.lako ? 'assets/icons/LakoSelected.svg' : 'assets/icons/LakoUnselected.svg'),
                                                      SvgPicture.asset('assets/icons/LakoUnselected.svg'),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        'Lako',
                                                        style: Theme.of(context).textTheme.headline5!.copyWith(
                                                              // color: tezina == Tezina.lako ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary,
                                                              color: Theme.of(context).colorScheme.primary,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      // tezina = Tezina.umjereno;
                                                      // tezinaValidator = false;
                                                    });
                                                  },
                                                  child: Row(
                                                    children: [
                                                      // SvgPicture.asset(tezina == Tezina.umjereno ? 'assets/icons/UmjerenoSelected.svg' : 'assets/icons/UmjerenoUnselected.svg'),
                                                      SvgPicture.asset('assets/icons/UmjerenoUnselected.svg'),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        'Umjereno',
                                                        style: Theme.of(context).textTheme.headline5!.copyWith(
                                                              // color: tezina == Tezina.umjereno ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary,
                                                              color: Theme.of(context).colorScheme.primary,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      // tezina = Tezina.tesko;
                                                      // tezinaValidator = false;
                                                    });
                                                  },
                                                  child: Row(
                                                    children: [
                                                      // SvgPicture.asset(tezina == Tezina.tesko ? 'assets/icons/TeskoSelected.svg' : 'assets/icons/TeskoUnselected.svg'),
                                                      SvgPicture.asset('assets/icons/TeskoUnselected.svg'),

                                                      const SizedBox(width: 5),
                                                      Text(
                                                        'Teško',
                                                        style: Theme.of(context).textTheme.headline5!.copyWith(
                                                              // color: tezina == Tezina.tesko ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary,
                                                              color: Theme.of(context).colorScheme.primary,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Vrijeme pripreme (minuti)',
                                            style: Theme.of(context).textTheme.headline3,
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              InputField(
                                                medijakveri: medijakveri,
                                                hintText: 'Od',
                                                inputAction: TextInputAction.next,
                                                inputType: TextInputType.number,
                                                obscureText: false,
                                                validator: (value) {},
                                                onSaved: (value) {},
                                                isMargin: false,
                                                isFixedWidth: true,
                                                fixedWidth: 80,
                                                isLabel: false,
                                                borderRadijus: 10,
                                              ),
                                              const SizedBox(width: 10),
                                              InputField(
                                                medijakveri: medijakveri,
                                                hintText: 'Do',
                                                inputAction: TextInputAction.next,
                                                inputType: TextInputType.number,
                                                obscureText: false,
                                                validator: (value) {},
                                                onSaved: (value) {},
                                                isMargin: false,
                                                isFixedWidth: true,
                                                fixedWidth: 80,
                                                isLabel: false,
                                                borderRadijus: 10,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Ocjena',
                                            style: Theme.of(context).textTheme.headline3,
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              InputField(
                                                medijakveri: medijakveri,
                                                hintText: 'Od',
                                                inputAction: TextInputAction.next,
                                                inputType: TextInputType.number,
                                                obscureText: false,
                                                validator: (value) {},
                                                onSaved: (value) {},
                                                isMargin: false,
                                                isFixedWidth: true,
                                                fixedWidth: 80,
                                                isLabel: false,
                                                borderRadijus: 10,
                                              ),
                                              const SizedBox(width: 10),
                                              InputField(
                                                medijakveri: medijakveri,
                                                hintText: 'Do',
                                                inputAction: TextInputAction.next,
                                                inputType: TextInputType.number,
                                                obscureText: false,
                                                validator: (value) {},
                                                onSaved: (value) {},
                                                isMargin: false,
                                                isFixedWidth: true,
                                                fixedWidth: 80,
                                                isLabel: false,
                                                borderRadijus: 10,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Tagovi',
                                            style: Theme.of(context).textTheme.headline2,
                                          ),
                                          const SizedBox(height: 10),
                                          GestureDetector(
                                            onTap: () {
                                              // if (tagovi.length == 5) {
                                              //   ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                              //   ScaffoldMessenger.of(context).showSnackBar(
                                              //     SnackBar(
                                              //       content: Text(
                                              //         'Ne možete dodati više od 5 tagova.',
                                              //         style: Theme.of(context).textTheme.headline4,
                                              //       ),
                                              //       duration: const Duration(milliseconds: 900),
                                              //       behavior: SnackBarBehavior.floating,
                                              //       backgroundColor: Theme.of(context).colorScheme.secondary,
                                              //       elevation: 4,
                                              //     ),
                                              //   );
                                              // }
                                            },
                                            child: Container(
                                              width: medijakveri.size.width - medijakveri.size.width * 0.14,
                                              child: MultipleSearchSelection<String>(
                                                items: localAvailableTagovi,
                                                fieldToCheck: (tag) {
                                                  return tag;
                                                },
                                                maxSelectedItems: 5,
                                                // textFieldFocus: tagNode,
                                                clearSearchFieldOnSelect: true,
                                                searchFieldTextStyle: Theme.of(context).textTheme.headline4,
                                                itemsVisibility: ShowedItemsVisibility.toggle,
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
                                                showItemsButton: Text('Izaberite tagove', style: Theme.of(context).textTheme.headline4),
                                                searchFieldBoxDecoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(20),
                                                ),

                                                searchFieldInputDecoration: InputDecoration(
                                                  hintText: "Potražite tag",
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                  hintStyle: Theme.of(context).textTheme.headline4?.copyWith(
                                                        color: Colors.grey,
                                                      ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  enabledBorder: const OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.transparent),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                    color: Theme.of(context).colorScheme.primary,
                                                  )),
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
                                                // onItemAdded: (itemName) {
                                                //   tagovi.add(itemName);
                                                //   setState(() {
                                                //     tagValidator = false;
                                                //   });
                                                // },
                                                // onItemRemoved: (itemName) {
                                                //   tagovi.removeWhere((elementName) => itemName == elementName);
                                                // },
                                                // onTapClearAll: () {
                                                //   tagovi.clear();
                                                // },
                                                showedItemsScrollbarColor: Colors.transparent,

                                                showedItemsBoxDecoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                maximumShowItemsHeight: 300,
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
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Button(
                                    buttonText: 'Primijenite filtere',
                                    borderRadius: 20,
                                    visina: 18,
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    isBorder: false,
                                    funkcija: () {},
                                    isFullWidth: true,
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Iconsax.filter_square,
                      color: Theme.of(context).primaryColor,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            StreamBuilder(
              stream: meals,
              builder: ((context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: (medijakveri.size.height - medijakveri.padding.top) * 0.66,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final receptDocs = snapshot.data!.docs;
                if (!isInternet!) {
                  return Container(
                    height: (medijakveri.size.height - medijakveri.padding.top) * 0.66,
                    child: Center(
                      child: Text(
                        'Nema internet konekcije',
                        style: Theme.of(context).textTheme.headline2,
                      ),
                    ),
                  );
                }
                if (receptDocs.isEmpty) {
                  return Container(
                    height: (medijakveri.size.height - medijakveri.padding.top) * 0.66,
                    child: Center(
                      child: Text(
                        'Nema recepata',
                        style: Theme.of(context).textTheme.headline2,
                      ),
                    ),
                  );
                }
                receptDocs.sort((a, b) {
                  if (DateTime.parse(a.data()['createdAt']).isAfter(DateTime.parse(b.data()['createdAt']))) {
                    return 0;
                  } else {
                    return 1;
                  }
                });
                return Container(
                  height: medijakveri.size.height * 0.66,
                  child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      separatorBuilder: ((context, index) => const SizedBox(height: 15)),
                      itemCount: receptDocs.length,
                      itemBuilder: (context, index) {
                        return MealCard(
                          medijakveri: medijakveri,
                          receptId: receptDocs[index].id,
                          autorId: receptDocs[index].data()['userId'],
                          naziv: receptDocs[index].data()['naziv'],
                          opis: receptDocs[index].data()['opis'],
                          brOsoba: receptDocs[index].data()['brOsoba'],
                          vrPripreme: receptDocs[index].data()['vrPripreme'],
                          tezina: receptDocs[index].data()['tezina'],
                          imageUrl: receptDocs[index].data()['imageUrl'],
                          createdAt: receptDocs[index].data()['createdAt'],
                          ratings: receptDocs[index].data()['ratings'],
                          sastojci: receptDocs[index].data()['sastojci'],
                          koraci: receptDocs[index].data()['koraci'],
                          favorites: receptDocs[index].data()['favorites'],
                          tagovi: receptDocs[index].data()['tagovi'],
                        );
                      }),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
