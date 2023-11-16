import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mealy/components/CustomAppbar.dart';
import 'package:provider/provider.dart';

import '../../components/MealCard.dart';
import '../../providers/MealProvider.dart';

class AccountViewScreen extends StatefulWidget {
  static const String routeName = '/AccountViewScreen';

  final String imageUrl;
  final String userName;
  final String userId;
  const AccountViewScreen({
    super.key,
    required this.imageUrl,
    required this.userName,
    required this.userId,
  });

  @override
  State<AccountViewScreen> createState() => _AccountViewScreenState();
}

class _AccountViewScreenState extends State<AccountViewScreen> {
  Stream<QuerySnapshot<Map<String, dynamic>>>? meals;

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    Provider.of<MealProvider>(context, listen: false).readMeals();
    meals = Provider.of<MealProvider>(context, listen: false).meals;
  }

  @override
  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: medijakveri.size.width * 0.07),
          child: Column(
            children: [
              CustomAppBar(
                pageTitle: 'Nalog',
                isCenter: true,
                prvaIkonica: Iconsax.back_square,
                prvaIkonicaFunkcija: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    widget.imageUrl == ''
                        ? SvgPicture.asset(
                            'assets/icons/Torta.svg',
                            height: 75,
                            width: 75,
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              '${widget.imageUrl}',
                              height: 75,
                              width: 75,
                              fit: BoxFit.fill,
                            ),
                          ),
                    const SizedBox(width: 10),
                    Text(
                      widget.userName,
                      style: Theme.of(context).textTheme.headline3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recepti',
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder(
                    stream: meals,
                    builder: ((context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height: (medijakveri.size.height - medijakveri.padding.top) * 0.68,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final receptDocs = snapshot.data!.docs;
                      List<dynamic> ownRecepti = [];

                      receptDocs.forEach((element) {
                        if (element['userId'] == widget.userId) {
                          ownRecepti.add(element);
                        }
                      });

                      if (ownRecepti.isEmpty || meals == null) {
                        return Container(
                          height: (medijakveri.size.height - medijakveri.padding.top) * 0.68,
                          child: Center(
                            child: Text(
                              'Nema recepata',
                              style: Theme.of(context).textTheme.headline2,
                            ),
                          ),
                        );
                      }

                      return Container(
                        height: (medijakveri.size.height - medijakveri.padding.top) * 0.68,
                        child: ListView.separated(
                            padding: EdgeInsets.zero,
                            separatorBuilder: ((context, index) => const SizedBox(height: 15)),
                            itemCount: ownRecepti.length,
                            itemBuilder: (context, index) {
                              int userRating = 0;
                              if (receptDocs[index].data()['ratings'][widget.userId] != null) {
                                userRating = receptDocs[index].data()['ratings'][widget.userId];
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
                                isAutorClick: false,
                              );
                            }),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
