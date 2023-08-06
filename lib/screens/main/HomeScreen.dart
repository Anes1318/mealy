import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final form = GlobalKey<FormState>();

  Stream<QuerySnapshot<Map<String, dynamic>>>? meals;

  bool? isInternet;
  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    Provider.of<MealProvider>(context).readMeals();
    meals = Provider.of<MealProvider>(context).meals;
    isInternet = Provider.of<MealProvider>(context).getIsInternet;
  }

  //
  //
  // FILTERI
  final tagNode = FocusNode();

  bool isFilter = false;
  AnimationController? _controller;
  late Animation<Offset> _offsetAnimation;
  bool isFilterLoading = false;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => showFilteri());
    WidgetsBinding.instance.addPostFrameCallback((_) => showFilterLoading());
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150), // Adjust the duration as needed
    )..repeat(reverse: true);

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Slide from bottom
      end: const Offset(0, 0.2),
    ).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.linear, // You can choose other curves for different effects
    ));
  }

  List<String> localAvailableTagovi = availableTagovi;

  Map<String, dynamic> filterData = {
    'brOsobaOd': '',
    'brOsobaDo': '',
    'vrPripremeOd': '',
    'vrPripremeDo': '',
    'ocjenaOd': '',
    'ocjenaDo': '',
  };

  List<String> tagovi = [];
  List<Tezina> filterTezina = [];
  List<String> tagoviReset = [];
  String brOsobaErrorMessage = '';
  String vrPripremeErrorMessage = '';
  String ocjenaErrorMessage = '';

  void submitFilters() {
    if (!form.currentState!.validate()) {
      return;
    }
    form.currentState!.save();
    //
    //
    // BROJ OSOBA
    if (filterData['brOsobaOd'] != '') {
      if (int.parse(filterData['brOsobaOd']) < 1 || int.parse(filterData['brOsobaOd']) > 20) {
        brOsobaErrorMessage = 'Broj osoba ne može biti manji od 0 ili veći od 20';
        entry!.markNeedsBuild();
        return;
      }
      if (filterData['brOsobaDo'] != '') {
        if (int.parse(filterData['brOsobaOd']) > int.parse(filterData['brOsobaDo'])) {
          brOsobaErrorMessage = 'Najmanji broj osoba ne može biti veći od najvećeg';
          entry!.markNeedsBuild();
          return;
        }
      }
      brOsobaErrorMessage = '';
      entry!.markNeedsBuild();
    }
    if (filterData['brOsobaDo'] != '') {
      if (int.parse(filterData['brOsobaDo']) < 1 || int.parse(filterData['brOsobaDo']) > 20) {
        brOsobaErrorMessage = 'Broj osoba ne može biti manji od 0 ili veći od 20';
        entry!.markNeedsBuild();
        return;
      }
      brOsobaErrorMessage = '';
      entry!.markNeedsBuild();
    }
    //
    //
    // VRIJEME PRIPREME
    if (filterData['vrPripremeOd'] != '') {
      if (int.parse(filterData['vrPripremeOd']) < 1 || int.parse(filterData['vrPripremeOd']) > 999) {
        vrPripremeErrorMessage = 'Vrijeme pripreme ne može biti manje od 0 ili veće od 999';
        entry!.markNeedsBuild();
        return;
      }
      if (filterData['vrPripremeDo'] != '') {
        if (int.parse(filterData['vrPripremeOd']) > int.parse(filterData['vrPripremeDo'])) {
          vrPripremeErrorMessage = 'Najmanje vrijeme pripreme ne može biti veće od najvećeg';
          entry!.markNeedsBuild();
          return;
        }
      }
      vrPripremeErrorMessage = '';
      entry!.markNeedsBuild();
    }
    if (filterData['vrPripremeDo'] != '') {
      if (int.parse(filterData['vrPripremeDo']) < 1 || int.parse(filterData['vrPripremeDo']) > 999) {
        vrPripremeErrorMessage = 'Vrijeme pripreme ne može biti manje od 0 ili veće od 999';
        entry!.markNeedsBuild();
        return;
      }
      vrPripremeErrorMessage = '';
      entry!.markNeedsBuild();
    }
    //
    //
    // OCJENA
    if (filterData['ocjenaOd'] != '') {
      if (double.parse(filterData['ocjenaOd']) < 1 || double.parse(filterData['ocjenaOd']) > 5) {
        ocjenaErrorMessage = 'Ocjena ne može biti manja od 0 ili veća od 5';
        entry!.markNeedsBuild();
        return;
      }
      if (filterData['ocjenaDo'] != '') {
        if (double.parse(filterData['ocjenaOd']) > double.parse(filterData['ocjenaDo'])) {
          ocjenaErrorMessage = 'Najmanja ocjena ne može biti veća od najveće';
          entry!.markNeedsBuild();
          return;
        }
      }
      ocjenaErrorMessage = '';
      entry!.markNeedsBuild();
    }
    if (filterData['ocjenaDo'] != '') {
      if (double.parse(filterData['ocjenaDo']) < 1 || double.parse(filterData['ocjenaDo']) > 5) {
        ocjenaErrorMessage = 'Ocjena ne može biti manja od 0 ili veća od 5';
        entry!.markNeedsBuild();
        return;
      }
      ocjenaErrorMessage = '';
      entry!.markNeedsBuild();
    }

    print(filterData);
  }

  // FILTER LOADING
  OverlayState? overlayLoading;
  OverlayEntry? entryLoading;

  void showFilterLoading() {
    overlayLoading = Overlay.of(context);
    entryLoading = OverlayEntry(builder: (context) {
      final medijakveri = MediaQuery.of(context);
      return Stack(
        children: [
          Positioned(
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                _controller!.reverse().whenComplete(() => hideFilteri());
              },
              child: Container(
                color: Colors.black.withOpacity(.3),
                width: medijakveri.size.width,
                height: (medijakveri.size.height - medijakveri.padding.top) * 1,
              ),
            ),
          ),
          const Center(
            child: CircularProgressIndicator(),
          ),
        ],
      );
    });
  }

  void hideFilterLoading() {
    entryLoading!.remove();
    entryLoading = null;
  }

  // FILTER
  OverlayState? overlay;
  OverlayEntry? entry;

  void showFilteri() {
    overlay = Overlay.of(context);

    entry = OverlayEntry(
      builder: (context) {
        final medijakveri = MediaQuery.of(context);
        final FocusScopeNode _focusScopeNode = FocusScopeNode();
        return Stack(
          children: [
            Positioned(
              bottom: 0,
              child: GestureDetector(
                onTap: () {
                  _controller!.reverse().whenComplete(() => hideFilteri());
                },
                child: Container(
                  color: Colors.black.withOpacity(.3),
                  width: medijakveri.size.width,
                  height: (medijakveri.size.height - medijakveri.padding.top) * 1,
                ),
              ),
            ),
            isFilterLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : SlideTransition(
                    position: _offsetAnimation,
                    child: Dismissible(
                      key: const Key('Filter'),
                      direction: DismissDirection.down,
                      dismissThresholds: const {
                        DismissDirection.down: 0.5,
                      },
                      onDismissed: (value) {
                        hideFilteri();
                        _controller!.reverse();
                      },
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: FocusScope(
                          node: _focusScopeNode,
                          child: Scaffold(
                            resizeToAvoidBottomInset: true,
                            key: const Key('Filter'),
                            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                            body: GestureDetector(
                              onTap: () => _focusScopeNode.unfocus(),
                              child: Container(
                                height: (medijakveri.size.height - medijakveri.padding.top) * 0.8,
                                padding: EdgeInsets.only(
                                  left: medijakveri.size.width * 0.07,
                                  right: medijakveri.size.width * 0.07,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                ),
                                child: ListView(
                                  // shrinkWrap: true,
                                  primary: false,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            form.currentState!.reset();
                                            filterTezina.clear();
                                            tagovi.clear();
                                            tagoviReset = [];
                                            brOsobaErrorMessage = '';
                                            vrPripremeErrorMessage = '';
                                            ocjenaErrorMessage = '';
                                            hideFilteri();
                                            showFilterLoading();
                                            overlayLoading!.insert(entryLoading!);

                                            await Future.delayed(
                                              const Duration(milliseconds: 200),
                                            );
                                            hideFilterLoading();
                                            showFilteri();
                                            overlay!.insert(entry!);
                                          },
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
                                            _controller!.reverse().whenComplete(() => hideFilteri());
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
                                                        textInputFormater: <TextInputFormatter>[
                                                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                                        ],
                                                        validator: (value) {},
                                                        onSaved: (value) {
                                                          filterData['brOsobaOd'] = value;
                                                        },
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
                                                        textInputFormater: <TextInputFormatter>[
                                                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                                        ],
                                                        validator: (value) {},
                                                        onSaved: (value) {
                                                          filterData['brOsobaDo'] = value;
                                                        },
                                                        isMargin: false,
                                                        isFixedWidth: true,
                                                        fixedWidth: 80,
                                                        isLabel: false,
                                                        borderRadijus: 10,
                                                      ),
                                                    ],
                                                  ),
                                                  if (brOsobaErrorMessage != '')
                                                    Column(
                                                      children: [
                                                        const SizedBox(height: 5),
                                                        Text(
                                                          brOsobaErrorMessage,
                                                          style: Theme.of(context).textTheme.headline5!.copyWith(
                                                                color: Colors.red,
                                                              ),
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
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            if (!filterTezina.contains(Tezina.lako)) {
                                                              filterTezina.add(Tezina.lako);
                                                              entry!.markNeedsBuild();
                                                            } else {
                                                              filterTezina.remove(Tezina.lako);
                                                              entry!.markNeedsBuild();
                                                            }
                                                          },
                                                          child: Container(
                                                            color: Colors.transparent,
                                                            child: Row(
                                                              children: [
                                                                SvgPicture.asset(filterTezina.contains(Tezina.lako) ? 'assets/icons/LakoSelected.svg' : 'assets/icons/LakoUnselected.svg'),
                                                                const SizedBox(width: 5),
                                                                Text(
                                                                  'Lako',
                                                                  style: Theme.of(context).textTheme.headline5!.copyWith(color: filterTezina.contains(Tezina.lako) ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            if (!filterTezina.contains(Tezina.umjereno)) {
                                                              filterTezina.add(Tezina.umjereno);
                                                              entry!.markNeedsBuild();
                                                            } else {
                                                              filterTezina.remove(Tezina.umjereno);
                                                              entry!.markNeedsBuild();
                                                            }
                                                          },
                                                          child: Container(
                                                            color: Colors.transparent,
                                                            child: Row(
                                                              children: [
                                                                SvgPicture.asset(filterTezina.contains(Tezina.umjereno) ? 'assets/icons/UmjerenoSelected.svg' : 'assets/icons/UmjerenoUnselected.svg'),
                                                                const SizedBox(width: 5),
                                                                Text(
                                                                  'Umjereno',
                                                                  style: Theme.of(context).textTheme.headline5!.copyWith(color: filterTezina.contains(Tezina.umjereno) ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            if (!filterTezina.contains(Tezina.tesko)) {
                                                              filterTezina.add(Tezina.tesko);
                                                              entry!.markNeedsBuild();
                                                            } else {
                                                              filterTezina.remove(Tezina.tesko);
                                                              entry!.markNeedsBuild();
                                                            }
                                                          },
                                                          child: Container(
                                                            color: Colors.transparent,
                                                            child: Row(
                                                              children: [
                                                                SvgPicture.asset(filterTezina.contains(Tezina.tesko) ? 'assets/icons/TeskoSelected.svg' : 'assets/icons/TeskoUnselected.svg'),
                                                                const SizedBox(width: 5),
                                                                Text(
                                                                  'Teško',
                                                                  style: Theme.of(context).textTheme.headline5!.copyWith(color: filterTezina.contains(Tezina.tesko) ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary),
                                                                ),
                                                              ],
                                                            ),
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
                                                        textInputFormater: <TextInputFormatter>[
                                                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                                        ],
                                                        validator: (value) {},
                                                        onSaved: (value) {
                                                          filterData['vrPripremeOd'] = value;
                                                        },
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
                                                        textInputFormater: <TextInputFormatter>[
                                                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                                        ],
                                                        validator: (value) {},
                                                        onSaved: (value) {
                                                          filterData['vrPripremeDo'] = value;
                                                        },
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
                                          if (vrPripremeErrorMessage != '')
                                            Container(
                                              width: medijakveri.size.width,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    vrPripremeErrorMessage,
                                                    style: Theme.of(context).textTheme.headline5!.copyWith(
                                                          color: Colors.red,
                                                        ),
                                                  ),
                                                ],
                                              ),
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
                                                        textInputFormater: <TextInputFormatter>[
                                                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                                        ],
                                                        validator: (value) {},
                                                        onSaved: (value) {
                                                          filterData['ocjenaOd'] = value;
                                                        },
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
                                                        textInputFormater: <TextInputFormatter>[
                                                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                                        ],
                                                        validator: (value) {},
                                                        onSaved: (value) {
                                                          filterData['ocjenaDo'] = value;
                                                        },
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
                                          if (ocjenaErrorMessage != '')
                                            Container(
                                              width: medijakveri.size.width,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    ocjenaErrorMessage,
                                                    style: Theme.of(context).textTheme.headline5!.copyWith(
                                                          color: Colors.red,
                                                        ),
                                                  ),
                                                ],
                                              ),
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
                                                  Container(
                                                    width: medijakveri.size.width - medijakveri.size.width * 0.14,
                                                    child: MultipleSearchSelection<String>(
                                                      items: localAvailableTagovi,
                                                      fieldToCheck: (tag) {
                                                        return tag;
                                                      },
                                                      maxSelectedItems: 5,
                                                      initialPickedItems: tagoviReset,
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
                                                      showItemsButton: Text('Izaberite tagove', style: Theme.of(context).textTheme.headline4),
                                                      searchFieldBoxDecoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      searchFieldInputDecoration: InputDecoration(
                                                        hintText: "Potražite tag",
                                                        contentPadding: const EdgeInsets.symmetric(
                                                          horizontal: 20,
                                                          vertical: 10,
                                                        ),
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
                                                      onItemAdded: (itemName) {
                                                        tagovi.add(itemName);
                                                      },
                                                      onItemRemoved: (itemName) {
                                                        tagovi.removeWhere((elementName) => itemName == elementName);
                                                      },
                                                      onTapClearAll: () {
                                                        tagovi.clear();
                                                      },
                                                      showedItemsScrollbarColor: Colors.transparent,
                                                      showedItemsBoxDecoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      maximumShowItemsHeight: 150,
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
                                            funkcija: () {
                                              submitFilters();
                                            },
                                            isFullWidth: true,
                                          ),
                                          const SizedBox(height: 60),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }

  void hideFilteri() {
    entry!.remove();
    entry = null;
  }

  @override
  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);

    return GestureDetector(
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
                  onTap: () async {
                    if (isFilter == false) {
                      brOsobaErrorMessage = '';
                      vrPripremeErrorMessage = '';
                      ocjenaErrorMessage = '';
                      showFilteri();
                      _controller!.addListener(() {
                        overlay!.setState(() {});
                      });
                      _controller!.forward();
                      overlay!.insert(entry!);
                      await Future.delayed(
                        Duration(milliseconds: 500),
                      );
                    }
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
            // AnimatedContainer(
            //   duration: Duration(milliseconds: 500),
            //   width: container,
            //   decoration: BoxDecoration(
            //     color: Colors.blue,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
