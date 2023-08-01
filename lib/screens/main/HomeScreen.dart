import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:iconsax/iconsax.dart';
import 'package:mealy/components/CustomAppbar.dart';
import 'package:mealy/components/MealCard.dart';
import 'package:provider/provider.dart';

import '../../components/metode.dart';
import '../../providers/MealProvider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                    print(isInternet);
                    // FirebaseAuth.instance.signOut();
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
