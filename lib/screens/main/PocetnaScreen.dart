import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:iconsax/iconsax.dart';
import 'package:mealy/components/CustomAppbar.dart';
import 'package:mealy/components/MealCard.dart';
import 'package:provider/provider.dart';

import '../../db/ReceptProvider.dart';

class PocetnaScreen extends StatefulWidget {
  const PocetnaScreen({super.key});

  @override
  State<PocetnaScreen> createState() => _PocetnaScreenState();
}

class _PocetnaScreenState extends State<PocetnaScreen> {
  Future<QuerySnapshot<Map<String, dynamic>>>? recepti;
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    Provider.of<ReceptProvider>(context).readRecepti();
    recepti = Provider.of<ReceptProvider>(context).recepti;
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
            FutureBuilder(
              future: recepti,
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

                return Container(
                  height: medijakveri.size.height * 0.66,
                  child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      separatorBuilder: ((context, index) => const SizedBox(height: 15)),
                      itemCount: receptDocs.length,
                      itemBuilder: (context, index) {
                        int userRating = 0;
                        if (receptDocs[index].data()['ratings'][FirebaseAuth.instance.currentUser!.uid] != null) {
                          userRating = receptDocs[index].data()['ratings'][FirebaseAuth.instance.currentUser!.uid];
                        }

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
                          ratings: receptDocs[index].data()['ratings'],
                          sastojci: receptDocs[index].data()['sastojci'],
                          koraci: receptDocs[index].data()['koraci'],
                          favorites: receptDocs[index].data()['favorites'],
                          tagovi: receptDocs[index].data()['tagovi'],
                          userRating: userRating,
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
