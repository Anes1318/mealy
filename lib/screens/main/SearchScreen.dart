import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mealy/components/CustomAppbar.dart';
import 'package:provider/provider.dart';

import '../../components/MealCard.dart';
import '../../models/tezina.dart';
import '../../providers/MealProvider.dart';

class SearchScreen extends StatefulWidget {
  static const String routeName = '/SearchScreen';
  final String? searchString;
  final Map<String, dynamic>? filterData;
  final List<String>? tagovi;
  final List<String>? tezina;
  final bool isFav;

  SearchScreen({
    super.key,
    this.searchString,
    this.filterData,
    this.tagovi,
    this.tezina,
    required this.isFav,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
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

  @override
  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: medijakveri.size.width * 0.07),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: (medijakveri.size.height - medijakveri.padding.top) * 0.035, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
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
                          widget.searchString ?? 'Pretraga po filterima',
                          style: Theme.of(context).textTheme.headline2,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Icon(
                        null,
                        size: 34,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              StreamBuilder(
                stream: meals,
                builder: ((context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: (medijakveri.size.height - medijakveri.padding.top) * 0.758,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final receptDocs = snapshot.data!.docs;
                  receptDocs.sort((a, b) {
                    if (DateTime.parse(a.data()['createdAt']).isAfter(DateTime.parse(b.data()['createdAt']))) {
                      return 0;
                    } else {
                      return 1;
                    }
                  });
                  List<dynamic> favRecepti = [];

                  if (widget.isFav) {
                    receptDocs.forEach((element) {
                      List<dynamic> listaUsera = (element.data()['favorites'].keys.map((item) => item as String)?.toList());
                      if (listaUsera.contains(FirebaseAuth.instance.currentUser!.uid)) {
                        favRecepti.add(element);
                      }
                    });
                  }

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
                  // print('STRING ${widget.searchString}');
                  // print(widget.filterData);
                  // print('TAGOVI ${widget.tagovi}');

                  //
                  //
                  // FILTRIRANJE
                  List<dynamic> searchedMeals = [];
                  if (widget.isFav) {
                    favRecepti.forEach((element) {
                      if (searchedMeals.contains(element)) {
                        return;
                      }
                      List<String> sastojciList = [];
                      for (var sastojak in element.data()['sastojci']) {
                        sastojciList.add(sastojak!.toLowerCase());
                      }
                      if (widget.searchString != null && widget.searchString != '') {
                        if (!element.data()['naziv']!.toLowerCase().contains(widget.searchString!.toLowerCase())) {
                          bool imaSastojak = false;
                          sastojciList.forEach((element) {
                            if (element.contains(widget.searchString!.toLowerCase())) {
                              imaSastojak = true;
                            }
                          });
                          if (!imaSastojak) {
                            return;
                          }
                        }
                      }
                      if (widget.filterData!['brOsobaOd'] != '') {
                        if (int.parse(element['brOsoba']) < int.parse(widget.filterData!['brOsobaOd'])) {
                          // print('Failed Osoba od');
                          return;
                        }
                      }
                      if (widget.filterData!['brOsobaDo'] != '') {
                        if (int.parse(element['brOsoba']) > int.parse(widget.filterData!['brOsobaDo'])) {
                          // print('Failed Osoba do');
                          return;
                        }
                      }

                      if (widget.tezina!.isNotEmpty) {
                        if (!widget.tezina!.contains(element['tezina'])) {
                          // print('Failed tezina');
                          return;
                        }
                      }

                      if (widget.filterData!['vrPripremeOd'] != '') {
                        if (int.parse(element['vrPripreme']) < int.parse(widget.filterData!['vrPripremeOd'])) {
                          // print('Failed vrijeme pripreme od');
                          return;
                        }
                      }
                      if (widget.filterData!['vrPripremeDo'] != '') {
                        if (int.parse(element['vrPripreme']) > int.parse(widget.filterData!['vrPripremeDo'])) {
                          // print('Failed vrijeme pripreme do');
                          return;
                        }
                      }
                      double rating = 0;
                      if (element['ratings'].values.isNotEmpty) {
                        for (var item in element['ratings'].values) {
                          rating += item;
                        }
                      }
                      rating /= element['ratings'].length;

                      if (widget.filterData!['ocjenaOd'] != '') {
                        if (rating < int.parse(widget.filterData!['ocjenaOd'])) {
                          print('Failed ocjena od');
                          return;
                        }
                      }
                      if (widget.filterData!['ocjenaDo'] != '') {
                        if (rating > int.parse(widget.filterData!['ocjenaDo'])) {
                          print('Failed ocjena do');
                          return;
                        }
                      }
                      if (widget.tagovi!.isNotEmpty) {
                        // print('WIDGET TAGOVI ${widget.tagovi}');
                        // print('ELEMENT TAGOVI ${element['tagovi']}');
                        List<String> nadjeniTagovi = [];

                        for (var i = 0; i < element['tagovi'].length; i++) {
                          if (widget.tagovi!.contains(element['tagovi'][i])) {
                            nadjeniTagovi.add(element['tagovi'][i]);
                          }
                        }
                        if (nadjeniTagovi.isEmpty) {
                          // print('NISMO NASLI NI JEDAN');
                          return;
                        }
                      }

                      // print('PROSO');
                      searchedMeals.add(element);
                    });
                  } else {
                    receptDocs.forEach((element) {
                      if (searchedMeals.contains(element)) {
                        return;
                      }
                      List<String> sastojciList = [];
                      for (var sastojak in element.data()['sastojci']) {
                        sastojciList.add(sastojak!.toLowerCase());
                      }
                      if (widget.searchString != null && widget.searchString != '') {
                        if (!element.data()['naziv']!.toLowerCase().contains(widget.searchString!.toLowerCase())) {
                          bool imaSastojak = false;
                          sastojciList.forEach((element) {
                            if (element.contains(widget.searchString!.toLowerCase())) {
                              imaSastojak = true;
                            }
                          });
                          if (!imaSastojak) {
                            return;
                          }
                        }
                      }

                      if (widget.filterData!['brOsobaOd'] != '') {
                        if (int.parse(element.data()['brOsoba']) < int.parse(widget.filterData!['brOsobaOd'])) {
                          // print('Failed Osoba od');
                          return;
                        }
                      }
                      if (widget.filterData!['brOsobaDo'] != '') {
                        if (int.parse(element.data()['brOsoba']) > int.parse(widget.filterData!['brOsobaDo'])) {
                          // print('Failed Osoba do');
                          return;
                        }
                      }

                      if (widget.tezina!.isNotEmpty) {
                        if (!widget.tezina!.contains(element.data()['tezina'])) {
                          // print('Failed tezina');
                          return;
                        }
                      }

                      if (widget.filterData!['vrPripremeOd'] != '') {
                        if (int.parse(element.data()['vrPripreme']) < int.parse(widget.filterData!['vrPripremeOd'])) {
                          // print('Failed vrijeme pripreme od');
                          return;
                        }
                      }
                      if (widget.filterData!['vrPripremeDo'] != '') {
                        if (int.parse(element.data()['vrPripreme']) > int.parse(widget.filterData!['vrPripremeDo'])) {
                          // print('Failed vrijeme pripreme do');
                          return;
                        }
                      }
                      double rating = 0;
                      if (element.data()['ratings'].values.isNotEmpty) {
                        for (var item in element.data()['ratings'].values) {
                          rating += item;
                        }
                      }
                      rating /= element.data()['ratings'].length;

                      if (widget.filterData!['ocjenaOd'] != '') {
                        if (rating < int.parse(widget.filterData!['ocjenaOd'])) {
                          print('Failed ocjena od');
                          return;
                        }
                      }
                      if (widget.filterData!['ocjenaDo'] != '') {
                        if (rating > int.parse(widget.filterData!['ocjenaDo'])) {
                          print('Failed ocjena do');
                          return;
                        }
                      }
                      if (widget.tagovi!.isNotEmpty) {
                        // print('WIDGET TAGOVI ${widget.tagovi}');
                        // print('ELEMENT TAGOVI ${element.data()['tagovi']}');
                        List<String> nadjeniTagovi = [];

                        for (var i = 0; i < element.data()['tagovi'].length; i++) {
                          if (widget.tagovi!.contains(element.data()['tagovi'][i])) {
                            nadjeniTagovi.add(element.data()['tagovi'][i]);
                          }
                        }
                        if (nadjeniTagovi.isEmpty) {
                          // print('NISMO NASLI NI JEDAN');
                          return;
                        }
                      }

                      // print('PROSO');
                      searchedMeals.add(element);
                    });
                  }

                  searchedMeals.sort((a, b) {
                    if (DateTime.parse(a.data()['createdAt']).isAfter(DateTime.parse(b.data()['createdAt']))) {
                      return 0;
                    } else {
                      return 1;
                    }
                  });
                  if (searchedMeals.isEmpty) {
                    return Container(
                      height: (medijakveri.size.height - medijakveri.padding.top) * 0.758,
                      child: Center(
                        child: Text(
                          widget.searchString != null && widget.searchString != '' ? 'Nema recepata za unijetu pretragu.' : 'Nema recepata za unijete filtere.',
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      ),
                    );
                  }

                  return Container(
                    height: medijakveri.size.height * 0.758,
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: searchedMeals.length,
                        itemBuilder: (context, index) {
                          int userRating = 0;
                          if (receptDocs[index].data()['ratings'][FirebaseAuth.instance.currentUser!.uid] != null) {
                            userRating = receptDocs[index].data()['ratings'][FirebaseAuth.instance.currentUser!.uid];
                          }
                          return MealCard(
                            medijakveri: medijakveri,
                            receptId: searchedMeals[index].id,
                            autorId: searchedMeals[index].data()['userId'],
                            naziv: searchedMeals[index].data()['naziv'],
                            opis: searchedMeals[index].data()['opis'],
                            brOsoba: searchedMeals[index].data()['brOsoba'],
                            vrPripreme: searchedMeals[index].data()['vrPripreme'],
                            tezina: searchedMeals[index].data()['tezina'],
                            imageUrl: searchedMeals[index].data()['imageUrl'],
                            createdAt: searchedMeals[index].data()['createdAt'],
                            ratings: searchedMeals[index].data()['ratings'],
                            sastojci: searchedMeals[index].data()['sastojci'],
                            koraci: searchedMeals[index].data()['koraci'],
                            favorites: searchedMeals[index].data()['favorites'],
                            tagovi: searchedMeals[index].data()['tagovi'],
                          );
                        }),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
