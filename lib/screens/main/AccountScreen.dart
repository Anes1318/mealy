import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mealy/components/metode.dart';
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

  DocumentSnapshot<Map<String, dynamic>>? user;
  Future<QuerySnapshot<Map<String, dynamic>>>? meals;

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    await Provider.of<MealProvider>(context).readUser(FirebaseAuth.instance.currentUser!.uid);
    user = Provider.of<MealProvider>(context, listen: false).user;
    Provider.of<MealProvider>(context, listen: false).readMeals();
    meals = Provider.of<MealProvider>(context, listen: false).meals;
    // print(user!.data()!['userName']);
  }

  @override
  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          CustomAppBar(
            pageTitle: 'Nalog',
            isCenter: false,
            drugaIkonica: Iconsax.setting_2,
            drugaIkonicaFunkcija: () {
              Provider.of<MealProvider>(context, listen: false).brFav;
            },
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: GestureDetector(
              onTap: () {}, // da vodi do edit screena
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      user!.data()!['imageUrl'] == ''
                          ? SvgPicture.asset(
                              'assets/icons/Torta.svg',
                              height: 75,
                              width: 75,
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                '${user!.data()!['imageUrl']}',
                                height: 75,
                                width: 75,
                                fit: BoxFit.fill,
                              ),
                            ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${user!.data()!['userName']}',
                            style: Theme.of(context).textTheme.headline3,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${user!.data()!['email']}',
                            style: Theme.of(context).textTheme.headline3,
                          ),
                        ],
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
              FutureBuilder(
                future: meals,
                builder: ((context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: (medijakveri.size.height - medijakveri.padding.top) * 0.54,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final receptDocs = snapshot.data!.docs;
                  List<dynamic> ownRecepti = [];

                  receptDocs.forEach((element) {
                    if (element['userId'] == FirebaseAuth.instance.currentUser!.uid) {
                      ownRecepti.add(element);
                    }
                  });

                  if (ownRecepti.isEmpty) {
                    return Container(
                      height: (medijakveri.size.height - medijakveri.padding.top) * 0.54,
                      child: Center(
                        child: Text(
                          'Nema recepata',
                          style: Theme.of(context).textTheme.headline2,
                        ),
                      ),
                    );
                  }

                  return Container(
                    height: (medijakveri.size.height - medijakveri.padding.top) * 0.54,
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
      ),
    );
  }
}
