import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/CustomAppbar.dart';
import '../../components/MealCard.dart';
import '../../providers/MealProvider.dart';

class FavoriteScreen extends StatefulWidget {
  static const String routeName = '/OmiljeniScreen';

  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  Stream<QuerySnapshot<Map<String, dynamic>>>? recepti;
  bool? isInternet;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    Provider.of<MealProvider>(context).readMeals();
    recepti = Provider.of<MealProvider>(context).meals;
    isInternet = Provider.of<MealProvider>(context).getIsInternet;
  }

  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          CustomAppBar(pageTitle: 'Omiljeni', isCenter: false),
          const SizedBox(height: 20),
          StreamBuilder(
            stream: recepti,
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
                  height: (medijakveri.size.height - medijakveri.padding.top) * 0.758,
                  child: Center(
                    child: Text(
                      'Nema omiljenih recepata',
                      style: Theme.of(context).textTheme.headline2,
                    ),
                  ),
                );
              }

              return Container(
                height: medijakveri.size.height * 0.758,
                child: ListView.separated(
                    padding: EdgeInsets.zero,
                    separatorBuilder: ((context, index) => const SizedBox(height: 15)),
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
                    }),
              );
            }),
          ),
        ],
      ),
    );
  }
}
