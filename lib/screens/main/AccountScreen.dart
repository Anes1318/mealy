import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';

import 'package:mealy/screens/account/AccountInfoScreen.dart';
import 'package:mealy/screens/settings/SettingsScreen.dart';
import 'package:provider/provider.dart';

import '../../components/CustomAppbar.dart';
import '../../components/MealCard.dart';
import '../../providers/MealProvider.dart';

class AccountScreen extends StatefulWidget {
  static const String routeName = '/NalogScreen';

  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isLoading = false;

  Stream<QuerySnapshot<Map<String, dynamic>>>? meals;
  bool? isInternet;

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    Provider.of<MealProvider>(context, listen: false).readMeals();
    meals = Provider.of<MealProvider>(context, listen: false).meals;
    isInternet = Provider.of<MealProvider>(context).getIsInternet;
  }

  @override
  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);
    return Column(
      children: [
        CustomAppBar(
          pageTitle: 'Nalog',
          isCenter: false,
          drugaIkonica: Iconsax.setting_2,
          drugaIkonicaFunkcija: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 150),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
                pageBuilder: (context, animation, duration) => SettingsScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            if (isInternet!) {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 150),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                  pageBuilder: (context, animation, duration) => AccountInfoScreen(),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    isInternet! == false
                        ? SvgPicture.asset(
                            'assets/icons/Torta.svg',
                            height: 75,
                            width: 75,
                          )
                        : FirebaseAuth.instance.currentUser!.photoURL == '' || FirebaseAuth.instance.currentUser!.photoURL == null
                            ? SvgPicture.asset(
                                'assets/icons/Torta.svg',
                                height: 75,
                                width: 75,
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  '${FirebaseAuth.instance.currentUser!.photoURL}',
                                  height: 75,
                                  width: 75,
                                  fit: BoxFit.fill,
                                ),
                              ),
                    const SizedBox(width: 10),
                    Container(
                      // width: 200,

                      width: medijakveri.size.width * 0.45,

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${FirebaseAuth.instance.currentUser!.displayName}',
                            style: Theme.of(context).textTheme.headline3,
                          ),
                          const SizedBox(height: 10),
                          FittedBox(
                            child: Text(
                              FirebaseAuth.instance.currentUser!.email!.length > 29 ? '${FirebaseAuth.instance.currentUser!.email!.substring(0, 29)}...' : FirebaseAuth.instance.currentUser!.email!,
                              style: Theme.of(context).textTheme.headline3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Theme.of(context).colorScheme.primary,
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Moji recepti',
              style: Theme.of(context).textTheme.headline2,
            ),
            const SizedBox(height: 10),
            StreamBuilder(
              stream: meals,
              builder: ((context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: (medijakveri.size.height - medijakveri.padding.top) * 0.57,
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
                List<dynamic> ownRecepti = [];

                receptDocs.forEach((element) {
                  if (element['userId'] == FirebaseAuth.instance.currentUser!.uid) {
                    ownRecepti.add(element);
                  }
                });

                if (ownRecepti.isEmpty || meals == null) {
                  return Container(
                    height: (medijakveri.size.height - medijakveri.padding.top) * 0.57,
                    child: Center(
                      child: Text(
                        'Nema recepata',
                        style: Theme.of(context).textTheme.headline2,
                      ),
                    ),
                  );
                }

                return Container(
                  height: (medijakveri.size.height - medijakveri.padding.top) * 0.57,
                  child: ListView.separated(
                      padding: EdgeInsets.zero,
                      separatorBuilder: ((context, index) => const SizedBox(height: 15)),
                      itemCount: ownRecepti.length,
                      itemBuilder: (context, index) {
                        int userRating = 0;
                        if (receptDocs[index].data()['ratings'][FirebaseAuth.instance.currentUser!.uid] != null) {
                          userRating = receptDocs[index].data()['ratings'][FirebaseAuth.instance.currentUser!.uid];
                        }
                        return MealCard(
                          medijakveri: medijakveri,
                          receptId: ownRecepti[index].id,
                          autorId: ownRecepti[index].data()['userId'],
                          naziv: ownRecepti[index].data()['naziv'],
                          opis: ownRecepti[index].data()['opis'],
                          brOsoba: ownRecepti[index].data()['brOsoba'],
                          vrPripreme: ownRecepti[index].data()['vrPripreme'],
                          tezina: ownRecepti[index].data()['tezina'],
                          imageUrl: ownRecepti[index].data()['imageUrl'],
                          createdAt: receptDocs[index].data()['createdAt'],
                          ratings: ownRecepti[index].data()['ratings'],
                          sastojci: ownRecepti[index].data()['sastojci'],
                          koraci: ownRecepti[index].data()['koraci'],
                          favorites: ownRecepti[index].data()['favorites'],
                          tagovi: ownRecepti[index].data()['tagovi'],
                        );
                      }),
                );
              }),
            ),
          ],
        ),
      ],
    );
  }
}
