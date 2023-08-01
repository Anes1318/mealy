import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:mealy/screens/account/AccountViewScreen.dart';
// screens
import 'package:mealy/screens/main/BottomNavigationBarScreen.dart';
import 'package:mealy/screens/meal/MealEditScreen.dart';
// components
import 'package:mealy/components/metode.dart';
import 'package:provider/provider.dart';

import '../../providers/MealProvider.dart';

class MealViewScreen extends StatefulWidget {
  static const String routeName = '/ReceptViewScreen';

  final String autorId;
  final String receptId;
  final String naziv;
  final String opis;
  final String brOsoba;
  final String vrPripreme;
  final String tezina;
  final String imageUrl;
  final String createdAt;
  final Map<String, dynamic> ratings;
  final List<dynamic> sastojci;
  final List<dynamic> koraci;
  final Map<String, dynamic> favorites;
  final List<dynamic> tagovi;

  MealViewScreen({
    required this.autorId,
    required this.receptId,
    required this.naziv,
    required this.opis,
    required this.brOsoba,
    required this.vrPripreme,
    required this.tezina,
    required this.imageUrl,
    required this.ratings,
    required this.sastojci,
    required this.koraci,
    required this.favorites,
    required this.tagovi,
    required this.createdAt,
  });

  @override
  State<MealViewScreen> createState() => _MealViewScreenState();
}

class _MealViewScreenState extends State<MealViewScreen> {
  bool isFav = false;

  double rating = 0;
  int userRating = 0;
  bool isInternet = false;

  MealProvider? ref;
  DocumentSnapshot<Map<String, dynamic>>? singleMeal;
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    ref = Provider.of<MealProvider>(context);
    await ref!.readSingleMeal(widget.receptId).then((value) {
      singleMeal = ref!.singleMeal;

      rating = 0;
      userRating = 0;
      if (singleMeal!.data()!['ratings'][FirebaseAuth.instance.currentUser!.uid] != null) {
        userRating = singleMeal!.data()!['ratings'][FirebaseAuth.instance.currentUser!.uid];
      }
      if (singleMeal!.data()!['ratings'].values.isNotEmpty) {
        for (var item in singleMeal!.data()!['ratings'].values) {
          rating += item;
        }
      }

      isFav = false;
      if (singleMeal!.data()!['favorites'].keys != null) {
        for (var element in singleMeal!.data()!['favorites'].keys) {
          if (element == FirebaseAuth.instance.currentUser!.uid) {
            setState(() {
              isFav = true;
            });
          }
        }
      }

      rating /= singleMeal!.data()!['ratings'].values.length;

      setState(() {});
    });
    try {
      final internetTest = await InternetAddress.lookup('google.com');
      isInternet = true;
    } catch (error) {
      isInternet = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = FirebaseFirestore.instance.collection('users').get();

    void favMeal() async {
      try {
        final internetTest = await InternetAddress.lookup('google.com');
      } catch (error) {
        Metode.showErrorDialog(
          isJednoPoredDrugog: false,
          message: "Došlo je do greške sa internetom. Provjerite svoju konekciju.",
          context: context,
          naslov: 'Greška',
          button1Text: 'Zatvori',
          button1Fun: () => {
            Navigator.pop(context),
          },
          isButton2: false,
        );
        return;
      }
      Provider.of<MealProvider>(context, listen: false).favMeal(singleMeal!.data()!['favorites'], widget.receptId);
    }

    final medijakveri = MediaQuery.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(0, 600),
        child: Container(
            child: SafeArea(
          child: Container(
            padding: EdgeInsets.only(top: (medijakveri.size.height - medijakveri.padding.top) * 0.035, bottom: 10),
            margin: EdgeInsets.symmetric(horizontal: medijakveri.size.width * 0.07),
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
                      widget.naziv,
                      style: Theme.of(context).textTheme.headline2,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => favMeal(),
                  child: widget.autorId != FirebaseAuth.instance.currentUser!.uid
                      ? SvgPicture.asset(
                          'assets/icons/${isFav}Heart.svg',
                          height: 28,
                          width: 30,
                        )
                      : GestureDetector(
                          onTap: () {
                            Metode.showErrorDialog(
                              isJednoPoredDrugog: false,
                              context: context,
                              naslov: 'Koju akciju želite da izvršite?',
                              button1Text: 'Izmijenite recept',
                              isButton1Icon: true,
                              button1Icon: Icon(
                                Iconsax.edit,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              button1Fun: () {
                                Navigator.pop(context);
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
                                    pageBuilder: (context, animation, duration) => MealEditScreen(
                                      naziv: widget.naziv,
                                      opis: widget.opis,
                                      brOsoba: widget.brOsoba,
                                      vrPripreme: widget.vrPripreme,
                                      tezina: widget.tezina,
                                      imageUrl: widget.imageUrl,
                                      ratings: widget.ratings,
                                      sastojci: widget.sastojci,
                                      koraci: widget.koraci,
                                      autorId: widget.autorId,
                                      receptId: widget.receptId,
                                      favorites: widget.favorites,
                                      tagovi: widget.tagovi,
                                    ),
                                  ),
                                );
                              },
                              isButton2: true,
                              button2Text: 'Izbrišite recept',
                              isButton2Icon: true,
                              button2Icon: Icon(
                                Iconsax.trash,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              button2Fun: () async {
                                try {
                                  await FirebaseFirestore.instance.collection('recepti').doc(widget.receptId).delete().then((value) async {
                                    await FirebaseStorage.instance.ref().child('receptImages').child('${widget.receptId}.jpg').delete().then((value) {
                                      Navigator.pushReplacementNamed(context, BottomNavigationBarScreen.routeName);
                                    });
                                  });
                                } catch (e) {
                                  Navigator.pushReplacementNamed(context, BottomNavigationBarScreen.routeName);
                                }

                                // Navigator.pop(context);
                              },
                            );
                          },
                          child: SvgPicture.asset(
                            'assets/icons/more.svg',
                          ),
                        ),
                ),
              ],
            ),
          ),
        )),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: medijakveri.size.width * 0.07),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      widget.imageUrl,
                      height: 200,
                      width: medijakveri.size.width,
                      fit: BoxFit.cover,
                    ),
                  ),

                  //
                  //
                  // STATS
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.clock,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${widget.vrPripreme} min',
                              style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.star,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              rating.isNaN ? '0.0' : rating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset('assets/icons/${widget.tezina}Unselected.svg'),
                            const SizedBox(height: 2),
                            Text(
                              widget.tezina == 'Tesko' ? 'Teško' : widget.tezina,
                              style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.people,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 2),
                            if (int.parse(widget.brOsoba) % 10 == 2 || int.parse(widget.brOsoba) % 10 == 3 || int.parse(widget.brOsoba) % 10 == 4)
                              Text(
                                '${widget.brOsoba} osobe',
                                style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 14),
                              ),
                            if (int.parse(widget.brOsoba) % 10 > 4 || int.parse(widget.brOsoba) % 10 == 1)
                              Text(
                                '${widget.brOsoba} osoba',
                                style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 14),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  //
                  //
                  // REJTING
                  if (widget.autorId != FirebaseAuth.instance.currentUser!.uid)
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Ocijenite ovaj recept',
                              style: Theme.of(context).textTheme.headline3,
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                ref!.rateMeal(context, widget.receptId, 1);
                              },
                              child: SvgPicture.asset(
                                userRating >= 1 ? 'assets/icons/trueStar.svg' : 'assets/icons/falseStar.svg',
                                height: 34,
                                width: 34,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                ref!.rateMeal(context, widget.receptId, 2);
                              },
                              child: SvgPicture.asset(
                                userRating >= 2 ? 'assets/icons/trueStar.svg' : 'assets/icons/falseStar.svg',
                                height: 34,
                                width: 34,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                ref!.rateMeal(context, widget.receptId, 3);
                              },
                              child: SvgPicture.asset(
                                userRating >= 3 ? 'assets/icons/trueStar.svg' : 'assets/icons/falseStar.svg',
                                height: 34,
                                width: 34,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                ref!.rateMeal(context, widget.receptId, 4);
                              },
                              child: SvgPicture.asset(
                                userRating >= 4 ? 'assets/icons/trueStar.svg' : 'assets/icons/falseStar.svg',
                                height: 34,
                                width: 34,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                ref!.rateMeal(context, widget.receptId, 5);
                              },
                              child: SvgPicture.asset(
                                userRating == 5 ? 'assets/icons/trueStar.svg' : 'assets/icons/falseStar.svg',
                                height: 34,
                                width: 34,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  //
                  //
                  // TAGOVI
                  const SizedBox(height: 20),
                  Container(
                    width: medijakveri.size.width,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tagovi',
                          style: Theme.of(context).textTheme.headline2,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 30,
                          child: ListView.separated(
                            separatorBuilder: (context, index) => const SizedBox(width: 10),
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true, // zauzima min content prostor
                            primary: false, // ne skrola ovu listu nego sve generalno
                            itemCount: widget.tagovi.length,
                            itemBuilder: ((context, index) => Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.tertiary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    child: Text(
                                      "#${widget.tagovi[index]}",
                                      style: Theme.of(context).textTheme.headline4!.copyWith(
                                            color: Colors.white,
                                          ),
                                    ),
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //
                  //
                  // OPIS
                  const SizedBox(height: 20),
                  Container(
                    width: medijakveri.size.width,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Opis',
                          style: Theme.of(context).textTheme.headline2,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.opis,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ],
                    ),
                  ),
                  //
                  //
                  // SASTOJCI
                  const SizedBox(height: 15),
                  Container(
                    width: medijakveri.size.width,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sastojci',
                          style: Theme.of(context).textTheme.headline2,
                        ),
                        const SizedBox(height: 10),
                        ListView.separated(
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          padding: EdgeInsets.zero,
                          shrinkWrap: true, // zauzima min content prostor
                          primary: false, // ne skrola ovu listu nego sve generalno
                          itemCount: widget.sastojci.length,
                          itemBuilder: ((context, index) => Row(
                                children: [
                                  Container(
                                    height: 10,
                                    width: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Container(
                                    width: medijakveri.size.width * 0.7,
                                    child: Text(
                                      '${widget.sastojci[index]}',
                                      style: Theme.of(context).textTheme.headline4,
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                  //
                  //
                  // KORACI
                  const SizedBox(height: 15),
                  Container(
                    width: medijakveri.size.width,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Koraci',
                            style: Theme.of(context).textTheme.headline2,
                          ),
                          const SizedBox(height: 10),
                          ListView.separated(
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            padding: EdgeInsets.zero,
                            shrinkWrap: true, // zauzima min content prostor
                            primary: false, // ne skrola ovu listu nego sve generalno
                            itemCount: widget.koraci.length,
                            itemBuilder: ((context, index) => Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.tertiary),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: Theme.of(context).textTheme.headline4!.copyWith(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Container(
                                      width: medijakveri.size.width * 0.65,
                                      child: Text(
                                        '${widget.koraci[index]}',
                                        style: Theme.of(context).textTheme.headline4,
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),

                  //
                  //
                  // AUTOR
                  const SizedBox(height: 20),

                  FutureBuilder(
                    future: users,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height: (medijakveri.size.height - medijakveri.padding.top) * 0.7,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final usersDocs = snapshot.data!.docs;

                      final user = usersDocs.where((element) => element['userId'] == widget.autorId).toList();

                      if (user.isEmpty) {
                        return Container(
                          height: (medijakveri.size.height - medijakveri.padding.top) * 0.7,
                          child: Center(
                            child: Text(
                              'Greška',
                              style: Theme.of(context).textTheme.headline2,
                            ),
                          ),
                        );
                      }

                      return GestureDetector(
                        onTap: () {
                          if (widget.autorId != FirebaseAuth.instance.currentUser!.uid) {
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
                                pageBuilder: (context, animation, duration) => AccountViewScreen(
                                  userName: user[0].data()['userName'],
                                  imageUrl: user[0].data()['imageUrl'],
                                  userId: user[0].data()['userId'],
                                ),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Autor',
                                style: Theme.of(context).textTheme.headline2,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  user[0].data()['imageUrl'] == ''
                                      ? SvgPicture.asset(
                                          'assets/icons/Torta.svg',
                                          height: 70,
                                          width: 70,
                                        )
                                      : ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: Image.network(
                                            '${user[0].data()['imageUrl']}',
                                            height: 70,
                                            width: 70,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${user[0].data()['userName']}',
                                        style: Theme.of(context).textTheme.headline3,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Objavljeno ${DateFormat('dd. MMM y.').format(DateTime.parse(widget.createdAt))}',
                                        style: Theme.of(context).textTheme.headline4,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
