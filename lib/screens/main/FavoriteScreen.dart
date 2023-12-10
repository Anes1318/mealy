import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:multiple_search_selection/multiple_search_selection.dart';
import 'package:provider/provider.dart';

import '../../components/Button.dart';
import '../../components/CustomAppbar.dart';
import '../../components/InputField.dart';
import '../../components/MealCard.dart';
import '../../models/availableTagovi.dart';
import '../../providers/MealProvider.dart';
import 'SearchScreen.dart';

class FavoriteScreen extends StatefulWidget {
  static const String routeName = '/OmiljeniScreen';

  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> with TickerProviderStateMixin {
  final form = GlobalKey<FormState>();

  final searchController = TextEditingController();

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

    WidgetsBinding.instance.addPostFrameCallback((_) => showFilters());
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
      curve: Curves.easeOut, // You can choose other curves for different effects
    ));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller!.dispose();
    super.dispose();
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
  String searchString = '';
  List<String> tagovi = [];
  List<String> filterTezina = [];
  String brOsobaErrorMessage = '';
  String vrPripremeErrorMessage = '';
  String ocjenaErrorMessage = '';

  bool submitFilters() {
    if (!form.currentState!.validate()) {
      return false;
    }
    form.currentState!.save();
    //
    //
    // BROJ OSOBA

    if (filterData['brOsobaOd'] == '' && filterData['brOsobaDo'] == '' && filterData['vrPripremeOd'] == '' && filterData['vrPripremeDo'] == '' && filterData['ocjenaOd'] == '' && filterData['ocjenaDo'] == '' && filterTezina.isEmpty && tagovi.isEmpty) {
      return false;
    }
    if (filterData['brOsobaOd'] != '') {
      if (int.parse(filterData['brOsobaOd']) < 1 || int.parse(filterData['brOsobaOd']) > 20) {
        brOsobaErrorMessage = 'Broj osoba ne može biti manji od 1 ili veći od 20';
        entry!.markNeedsBuild();
        return false;
      }

      if (filterData['brOsobaDo'] != '') {
        if (int.parse(filterData['brOsobaOd']) > int.parse(filterData['brOsobaDo'])) {
          brOsobaErrorMessage = 'Najmanji broj osoba ne može biti veći od najvećeg';
          entry!.markNeedsBuild();
          return false;
        }
      }
      brOsobaErrorMessage = '';
      entry!.markNeedsBuild();
    }
    if (filterData['brOsobaDo'] != '') {
      if (int.parse(filterData['brOsobaDo']) < 1 || int.parse(filterData['brOsobaDo']) > 20) {
        brOsobaErrorMessage = 'Broj osoba ne može biti manji od 1 ili veći od 20';
        entry!.markNeedsBuild();
        return false;
      }
      brOsobaErrorMessage = '';
      entry!.markNeedsBuild();
    }
    //
    //
    // VRIJEME PRIPREME
    if (filterData['vrPripremeOd'] != '') {
      if (int.parse(filterData['vrPripremeOd']) < 1 || int.parse(filterData['vrPripremeOd']) > 999) {
        vrPripremeErrorMessage = 'Vrijeme pripreme ne može biti manje od 1 ili veće od 999';
        entry!.markNeedsBuild();
        return false;
      }
      if (filterData['vrPripremeDo'] != '') {
        if (int.parse(filterData['vrPripremeOd']) > int.parse(filterData['vrPripremeDo'])) {
          vrPripremeErrorMessage = 'Najmanje vrijeme pripreme ne može biti veće od najvećeg';
          entry!.markNeedsBuild();
          return false;
        }
      }
      vrPripremeErrorMessage = '';
      entry!.markNeedsBuild();
    }
    if (filterData['vrPripremeDo'] != '') {
      if (int.parse(filterData['vrPripremeDo']) < 1 || int.parse(filterData['vrPripremeDo']) > 999) {
        vrPripremeErrorMessage = 'Vrijeme pripreme ne može biti manje od 1 ili veće od 999';
        entry!.markNeedsBuild();
        return false;
      }
      vrPripremeErrorMessage = '';
      entry!.markNeedsBuild();
    }
    //
    //
    // OCJENA
    if (filterData['ocjenaOd'] != '') {
      if (double.parse(filterData['ocjenaOd']) < 0 || double.parse(filterData['ocjenaOd']) > 5) {
        ocjenaErrorMessage = 'Ocjena ne može biti manja od 0 ili veća od 5';
        entry!.markNeedsBuild();
        return false;
      }
      if (filterData['ocjenaDo'] != '') {
        if (double.parse(filterData['ocjenaOd']) > double.parse(filterData['ocjenaDo'])) {
          ocjenaErrorMessage = 'Najmanja ocjena ne može biti veća od najveće';
          entry!.markNeedsBuild();
          return false;
        }
      }
      ocjenaErrorMessage = '';
      entry!.markNeedsBuild();
    }
    if (filterData['ocjenaDo'] != '') {
      if (double.parse(filterData['ocjenaDo']) < 0 || double.parse(filterData['ocjenaDo']) > 5) {
        ocjenaErrorMessage = 'Ocjena ne može biti manja od 0 ili veća od 5';
        entry!.markNeedsBuild();
        return false;
      }
      ocjenaErrorMessage = '';
      entry!.markNeedsBuild();
    }

    return true;
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
                _controller!.reverse().whenComplete(() => hideFilters());
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

  void showFilters() {
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
                  _controller!.reverse().whenComplete(() => hideFilters());
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
                        hideFilters();
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
                            key: const Key('skafoldKey'),
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
                                  //
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

                                            brOsobaErrorMessage = '';
                                            vrPripremeErrorMessage = '';
                                            ocjenaErrorMessage = '';
                                            hideFilters();
                                            showFilterLoading();
                                            overlayLoading!.insert(entryLoading!);

                                            await Future.delayed(
                                              const Duration(milliseconds: 200),
                                            );
                                            hideFilterLoading();
                                            showFilters();
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
                                            _controller!.reverse().whenComplete(() => hideFilters());
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
                                                        validator: (value) {
                                                          return null;
                                                        },
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
                                                        validator: (value) {
                                                          return null;
                                                        },
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
                                                            if (!filterTezina.contains('Lako')) {
                                                              filterTezina.add('Lako');
                                                              entry!.markNeedsBuild();
                                                            } else {
                                                              filterTezina.remove('Lako');
                                                              entry!.markNeedsBuild();
                                                            }
                                                          },
                                                          child: Container(
                                                            color: Colors.transparent,
                                                            child: Row(
                                                              children: [
                                                                SvgPicture.asset(filterTezina.contains('Lako') ? 'assets/icons/LakoSelected.svg' : 'assets/icons/LakoUnselected.svg'),
                                                                const SizedBox(width: 5),
                                                                Text(
                                                                  'Lako',
                                                                  style: Theme.of(context).textTheme.headline5!.copyWith(color: filterTezina.contains('Lako') ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            if (!filterTezina.contains('Umjereno')) {
                                                              filterTezina.add('Umjereno');
                                                              entry!.markNeedsBuild();
                                                            } else {
                                                              filterTezina.remove('Umjereno');
                                                              entry!.markNeedsBuild();
                                                            }
                                                          },
                                                          child: Container(
                                                            color: Colors.transparent,
                                                            child: Row(
                                                              children: [
                                                                SvgPicture.asset(filterTezina.contains('Umjereno') ? 'assets/icons/UmjerenoSelected.svg' : 'assets/icons/UmjerenoUnselected.svg'),
                                                                const SizedBox(width: 5),
                                                                Text(
                                                                  'Umjereno',
                                                                  style: Theme.of(context).textTheme.headline5!.copyWith(color: filterTezina.contains('Umjereno') ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            if (!filterTezina.contains('Tesko')) {
                                                              filterTezina.add('Tesko');
                                                              entry!.markNeedsBuild();
                                                            } else {
                                                              filterTezina.remove('Tesko');
                                                              entry!.markNeedsBuild();
                                                            }
                                                          },
                                                          child: Container(
                                                            color: Colors.transparent,
                                                            child: Row(
                                                              children: [
                                                                SvgPicture.asset(filterTezina.contains('Tesko') ? 'assets/icons/TeskoSelected.svg' : 'assets/icons/TeskoUnselected.svg'),
                                                                const SizedBox(width: 5),
                                                                Text(
                                                                  'Teško',
                                                                  style: Theme.of(context).textTheme.headline5!.copyWith(color: filterTezina.contains('Tesko') ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary),
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
                                                        validator: (value) {
                                                          return null;
                                                        },
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
                                                        validator: (value) {
                                                          return null;
                                                        },
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
                                                        validator: (value) {
                                                          return null;
                                                        },
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
                                                        validator: (value) {
                                                          return null;
                                                        },
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
                                                      clearSearchFieldOnSelect: true,
                                                      searchField: TextField(
                                                        focusNode: tagNode,
                                                        style: Theme.of(context).textTheme.headline4,
                                                        decoration: InputDecoration(
                                                          hintText: "Potražite tag",
                                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                          hintStyle: Theme.of(context).textTheme.headline4?.copyWith(
                                                                color: Colors.grey,
                                                              ),
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                          enabledBorder: OutlineInputBorder(
                                                            borderSide: const BorderSide(color: Colors.transparent),
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                          border: OutlineInputBorder(
                                                            borderSide: const BorderSide(color: Colors.transparent),
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                        ),
                                                      ),
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
                                              if (submitFilters()) {
                                                _controller!.reverse().whenComplete(() => hideFilters());
                                              }
                                            },
                                            isFullWidth: true,
                                          ),
                                          const SizedBox(height: 20),
                                          Button(
                                            buttonText: 'Pretraga po filterima',
                                            borderRadius: 20,
                                            visina: 18,
                                            backgroundColor: Theme.of(context).colorScheme.secondary,
                                            isBorder: true,
                                            textColor: Theme.of(context).colorScheme.primary,
                                            funkcija: () {
                                              submitFilters();
                                              if (!submitFilters()) {
                                                return;
                                              }
                                              hideFilters();
                                              FocusManager.instance.primaryFocus!.unfocus();
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  transitionDuration: const Duration(milliseconds: 120),
                                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                    return SlideTransition(
                                                      position: Tween<Offset>(
                                                        begin: const Offset(1, 0),
                                                        end: Offset.zero,
                                                      ).animate(animation),
                                                      child: child,
                                                    );
                                                  },
                                                  pageBuilder: (context, animation, duration) => SearchScreen(
                                                    searchString: null,
                                                    filterData: filterData,
                                                    tagovi: tagovi,
                                                    tezina: filterTezina,
                                                    isFav: true,
                                                  ),
                                                ),
                                              );
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

  void hideFilters() {
    entry!.remove();
    entry = null;
  }

  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus!.unfocus();
      },
      child: WillPopScope(
        onWillPop: () async {
          if (entry != null) {
            _controller!.reverse().whenComplete(() => hideFilters());
          }

          return false;
        },
        child: Column(
          children: [
            CustomAppBar(pageTitle: 'Omiljeni', isCenter: false),
            SizedBox(height: (medijakveri.size.height - medijakveri.padding.top) * 0.025),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: medijakveri.size.width * 0.7,
                  child: TextFormField(
                    controller: searchController,
                    onChanged: (value) {
                      searchString = value.trim();
                    },
                    onFieldSubmitted: (_) {
                      if (searchString == '') {
                        return;
                      }
                      FocusManager.instance.primaryFocus!.unfocus();

                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 120),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            );
                          },
                          pageBuilder: (context, animation, duration) => SearchScreen(
                            searchString: searchString,
                            filterData: filterData,
                            tagovi: tagovi,
                            tezina: filterTezina,
                            isFav: true,
                          ),
                        ),
                      );
                    },
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
                      suffixIcon: GestureDetector(
                        onTap: () {
                          if (searchString == '') {
                            return;
                          }
                          FocusManager.instance.primaryFocus!.unfocus();
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 120),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                );
                              },
                              pageBuilder: (context, animation, duration) => SearchScreen(
                                searchString: searchString,
                                filterData: filterData,
                                tagovi: tagovi,
                                tezina: filterTezina,
                                isFav: true,
                              ),
                            ),
                          );
                        },
                        child: const Icon(Iconsax.search_normal),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    if (isFilter == false) {
                      FocusManager.instance.primaryFocus!.unfocus();
                      brOsobaErrorMessage = '';
                      vrPripremeErrorMessage = '';
                      ocjenaErrorMessage = '';

                      filterTezina.clear();
                      tagovi.clear();
                      showFilters();
                      _controller!.addListener(() {
                        overlay!.setState(() {});
                      });
                      _controller!.forward();
                      overlay!.insert(entry!);
                      await Future.delayed(
                        const Duration(milliseconds: 500),
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
            SizedBox(height: (medijakveri.size.height - medijakveri.padding.top) * 0.025),
            StreamBuilder(
              stream: meals,
              builder: ((context, snapshot) {
                final receptDocs = snapshot.data!.docs;
                if (snapshot.connectionState == ConnectionState.none) {
                  return Container(
                    height: (medijakveri.size.height - medijakveri.padding.top) * 0.668,
                    child: const Center(
                      child: CircularProgressIndicator(),
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
                List<dynamic> favRecepti = [];
                if (!isInternet!) {
                  return Container(
                    height: (medijakveri.size.height - medijakveri.padding.top) * 0.668,
                    child: Center(
                      child: Text(
                        'Nema internet konekcije',
                        style: Theme.of(context).textTheme.headline2,
                      ),
                    ),
                  );
                }
                receptDocs.forEach((element) {
                  List<dynamic> listaUsera = (element.data()['favorites'].keys.map((item) => item as String)?.toList());
                  if (listaUsera.contains(FirebaseAuth.instance.currentUser!.uid)) {
                    favRecepti.add(element);
                  }
                });

                favRecepti.sort((a, b) {
                  if (DateTime.parse(a['favorites'].values.toString().replaceAll(RegExp(r'[()]'), '')).isAfter(DateTime.parse(b['favorites'].values.toString().replaceAll(RegExp(r'[()]'), '')))) {
                    return 0;
                  } else {
                    return 1;
                  }
                });
                if (favRecepti.isEmpty) {
                  return Container(
                    height: (medijakveri.size.height - medijakveri.padding.top) * 0.668,
                    child: Center(
                      child: Text(
                        'Nema omiljenih recepata',
                        style: Theme.of(context).textTheme.headline2,
                      ),
                    ),
                  );
                }

                return Container(
                  height: (medijakveri.size.height - medijakveri.padding.top) * 0.668,
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    separatorBuilder: ((context, index) => const SizedBox(height: 10)),
                    itemCount: favRecepti.length,
                    itemBuilder: (context, index) {
                      int userRating = 0;
                      if (receptDocs[index].data()['ratings'][FirebaseAuth.instance.currentUser!.uid] != null) {
                        userRating = receptDocs[index].data()['ratings'][FirebaseAuth.instance.currentUser!.uid];
                      }
                      return MealCard(
                        medijakveri: medijakveri,
                        receptId: favRecepti[index].id,
                        autorId: favRecepti[index].data()['userId'],
                        naziv: favRecepti[index].data()['naziv'],
                        opis: favRecepti[index].data()['opis'],
                        brOsoba: favRecepti[index].data()['brOsoba'],
                        vrPripreme: favRecepti[index].data()['vrPripreme'],
                        tezina: favRecepti[index].data()['tezina'],
                        imageUrl: favRecepti[index].data()['imageUrl'],
                        createdAt: receptDocs[index].data()['createdAt'],
                        ratings: favRecepti[index].data()['ratings'],
                        sastojci: favRecepti[index].data()['sastojci'],
                        koraci: favRecepti[index].data()['koraci'],
                        favorites: favRecepti[index].data()['favorites'],
                        tagovi: favRecepti[index].data()['tagovi'],
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
