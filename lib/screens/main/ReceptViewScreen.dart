import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mealy/components/CustomAppbar.dart';
import 'package:mealy/components/metode.dart';
import 'package:mealy/screens/main/BottomNavigationBarScreen.dart';
import 'package:mealy/screens/main/PocetnaScreen.dart';

class ReceptViewScreen extends StatefulWidget {
  static const String routeName = '/ReceptViewScreen';

  const ReceptViewScreen({
    super.key,
  });

  @override
  State<ReceptViewScreen> createState() => _ReceptViewScreenState();
}

class _ReceptViewScreenState extends State<ReceptViewScreen> {
  bool isFav = false;
  Map<String, dynamic>? args;
  List<String>? favList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    for (var element in args!['favorites']) {
      favList!.add(element);
    }
  }

  bool favMijenjan = false;
  @override
  Widget build(BuildContext context) {
    final users = FirebaseFirestore.instance.collection('users').get();

    if (favList != null) {
      for (var element in favList!) {
        if (element == FirebaseAuth.instance.currentUser!.uid) {
          setState(() {
            isFav = true;
          });
        }
      }
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
                InkWell(
                  onTap: () {
                    if (favMijenjan == false) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, BottomNavigationBarScreen.routeName);
                    }
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
                      args!['naziv'],
                      style: Theme.of(context).textTheme.headline2,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    try {
                      final internetTest = await InternetAddress.lookup('google.com');
                    } catch (error) {
                      Metode.showErrorDialog(
                        message: "Došlo je do greške sa internetom. Provjerite svoju konekciju.",
                        context: context,
                        naslov: 'Greška',
                        button1Text: 'Zatvori',
                        button1Fun: () => {Navigator.pop(context)},
                        isButton2: false,
                      );
                      return;
                    }
                    if (isFav) {
                      await FirebaseFirestore.instance.collection('recepti').doc(args!['receptId']).update({
                        'favorites': FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
                      }).then((value) {
                        setState(() {
                          isFav = false;
                          favList!.remove(FirebaseAuth.instance.currentUser!.uid);
                          favMijenjan = true;
                        });
                      });
                    } else {
                      await FirebaseFirestore.instance.collection('recepti').doc(args!['receptId']).update({
                        'favorites': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
                      }).then((value) {
                        setState(() {
                          isFav = true;
                          favList!.add(FirebaseAuth.instance.currentUser!.uid);
                          favMijenjan = true;
                        });
                      });
                    }
                  },
                  child: SvgPicture.asset(
                    'assets/icons/${isFav}Heart.svg',
                    height: 28,
                    width: 30,
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
                  Hero(
                    tag: args!['receptId'],
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        args!['imageUrl'],
                        height: 200,
                        width: medijakveri.size.width,
                        fit: BoxFit.cover,
                      ),
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
                              '${args!['vrPripreme']} min',
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
                              '0.0',
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
                            SvgPicture.asset('assets/icons/${args!['tezina']}Unselected.svg'),
                            const SizedBox(height: 2),
                            Text(
                              args!['tezina'] == 'Tesko' ? 'Teško' : args!['tezina'],
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
                            if (int.parse(args!['brOsoba']) % 10 == 2 || int.parse(args!['brOsoba']) % 10 == 3 || int.parse(args!['brOsoba']) % 10 == 4)
                              Text(
                                '${args!['brOsoba']} osobe',
                                style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 14),
                              ),
                            if (int.parse(args!['brOsoba']) % 10 > 4 || int.parse(args!['brOsoba']) % 10 == 1)
                              Text(
                                '${args!['brOsoba']} osoba',
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
                          Metode.showErrorDialog(
                            context: context,
                            naslov: 'Da li želite da ocijenite ovaj recept sa 1 zvjezdicom?',
                            button1Text: 'Potvrdi',
                            button1Fun: () async {
                              try {
                                final internetTest = await InternetAddress.lookup('google.com');
                              } catch (error) {
                                Navigator.pop(context);

                                Metode.showErrorDialog(
                                  message: "Došlo je do greške sa internetom. Provjerite svoju konekciju.",
                                  context: context,
                                  naslov: 'Greška',
                                  button1Text: 'Zatvori',
                                  button1Fun: () => {Navigator.pop(context)},
                                  isButton2: false,
                                );
                                return;
                              }
                              try {
                                FirebaseFirestore.instance.collection('recepti').doc(args!['receptId']).set(
                                  {
                                    'ratings': {
                                      FirebaseAuth.instance.currentUser!.uid: 1,
                                    },
                                  },
                                  SetOptions(merge: true),
                                ).then((value) {
                                  setState(() {
                                    args!['userRating'] = 1;
                                  });
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Vaša ocjena je zabilježena.',
                                        style: Theme.of(context).textTheme.headline4,
                                      ),
                                      duration: const Duration(milliseconds: 1500),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Theme.of(context).colorScheme.secondary,
                                      elevation: 4,
                                    ),
                                  );
                                });
                              } catch (e) {
                                Navigator.pop(context);

                                Metode.showErrorDialog(
                                  context: context,
                                  naslov: 'Došlo je do greške',
                                  button1Text: 'Zatvori',
                                  button1Fun: () {
                                    Navigator.pop(context);
                                  },
                                  isButton2: false,
                                );
                              }
                            },
                            isButton2: true,
                            button2Text: 'Otkaži',
                            button2Fun: () {
                              Navigator.pop(context);
                            },
                          );
                        },
                        child: SvgPicture.asset(
                          args!['userRating'] >= 1 ? 'assets/icons/trueStar.svg' : 'assets/icons/falseStar.svg',
                          height: 34,
                          width: 34,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Metode.showErrorDialog(
                            context: context,
                            naslov: 'Da li želite da ocijenite ovaj recept sa 2 zvjezdice?',
                            button1Text: 'Potvrdi',
                            button1Fun: () async {
                              try {
                                final internetTest = await InternetAddress.lookup('google.com');
                              } catch (error) {
                                Navigator.pop(context);

                                Metode.showErrorDialog(
                                  message: "Došlo je do greške sa internetom. Provjerite svoju konekciju.",
                                  context: context,
                                  naslov: 'Greška',
                                  button1Text: 'Zatvori',
                                  button1Fun: () => {Navigator.pop(context)},
                                  isButton2: false,
                                );
                                return;
                              }
                              try {
                                FirebaseFirestore.instance.collection('recepti').doc(args!['receptId']).update(
                                  {
                                    'ratings': {
                                      FirebaseAuth.instance.currentUser!.uid: 2,
                                    },
                                  },
                                ).then((value) {
                                  setState(() {
                                    args!['userRating'] = 2;
                                  });
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Vaša ocjena je zabilježena.',
                                        style: Theme.of(context).textTheme.headline4,
                                      ),
                                      duration: const Duration(milliseconds: 1500),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Theme.of(context).colorScheme.secondary,
                                      elevation: 4,
                                    ),
                                  );
                                });
                              } catch (e) {
                                Navigator.pop(context);

                                Metode.showErrorDialog(
                                  context: context,
                                  naslov: 'Došlo je do greške',
                                  button1Text: 'Zatvori',
                                  button1Fun: () {
                                    Navigator.pop(context);
                                  },
                                  isButton2: false,
                                );
                              }
                            },
                            isButton2: true,
                            button2Text: 'Otkaži',
                            button2Fun: () {
                              Navigator.pop(context);
                            },
                          );
                        },
                        child: SvgPicture.asset(
                          args!['userRating'] >= 2 ? 'assets/icons/trueStar.svg' : 'assets/icons/falseStar.svg',
                          height: 34,
                          width: 34,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Metode.showErrorDialog(
                            context: context,
                            naslov: 'Da li želite da ocijenite ovaj recept sa 3 zvjezdice?',
                            button1Text: 'Potvrdi',
                            button1Fun: () async {
                              try {
                                final internetTest = await InternetAddress.lookup('google.com');
                              } catch (error) {
                                Navigator.pop(context);

                                Metode.showErrorDialog(
                                  message: "Došlo je do greške sa internetom. Provjerite svoju konekciju.",
                                  context: context,
                                  naslov: 'Greška',
                                  button1Text: 'Zatvori',
                                  button1Fun: () => {Navigator.pop(context)},
                                  isButton2: false,
                                );
                                return;
                              }
                              try {
                                FirebaseFirestore.instance.collection('recepti').doc(args!['receptId']).update(
                                  {
                                    'ratings': {
                                      FirebaseAuth.instance.currentUser!.uid: 3,
                                    },
                                  },
                                ).then((value) {
                                  setState(() {
                                    args!['userRating'] = 3;
                                  });
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Vaša ocjena je zabilježena.',
                                        style: Theme.of(context).textTheme.headline4,
                                      ),
                                      duration: const Duration(milliseconds: 1500),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Theme.of(context).colorScheme.secondary,
                                      elevation: 4,
                                    ),
                                  );
                                });
                              } catch (e) {
                                Navigator.pop(context);

                                Metode.showErrorDialog(
                                  context: context,
                                  naslov: 'Došlo je do greške',
                                  button1Text: 'Zatvori',
                                  button1Fun: () {
                                    Navigator.pop(context);
                                  },
                                  isButton2: false,
                                );
                              }
                            },
                            isButton2: true,
                            button2Text: 'Otkaži',
                            button2Fun: () {
                              Navigator.pop(context);
                            },
                          );
                        },
                        child: SvgPicture.asset(
                          args!['userRating'] >= 3 ? 'assets/icons/trueStar.svg' : 'assets/icons/falseStar.svg',
                          height: 34,
                          width: 34,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Metode.showErrorDialog(
                            context: context,
                            naslov: 'Da li želite da ocijenite ovaj recept sa 4 zvjezdice?',
                            button1Text: 'Potvrdi',
                            button1Fun: () async {
                              try {
                                final internetTest = await InternetAddress.lookup('google.com');
                              } catch (error) {
                                Navigator.pop(context);

                                Metode.showErrorDialog(
                                  message: "Došlo je do greške sa internetom. Provjerite svoju konekciju.",
                                  context: context,
                                  naslov: 'Greška',
                                  button1Text: 'Zatvori',
                                  button1Fun: () => {Navigator.pop(context)},
                                  isButton2: false,
                                );
                                return;
                              }
                              try {
                                FirebaseFirestore.instance.collection('recepti').doc(args!['receptId']).update(
                                  {
                                    'ratings': {
                                      FirebaseAuth.instance.currentUser!.uid: 4,
                                    },
                                  },
                                ).then((value) {
                                  setState(() {
                                    args!['userRating'] = 4;
                                  });
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Vaša ocjena je zabilježena.',
                                        style: Theme.of(context).textTheme.headline4,
                                      ),
                                      duration: const Duration(milliseconds: 1500),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Theme.of(context).colorScheme.secondary,
                                      elevation: 4,
                                    ),
                                  );
                                });
                              } catch (e) {
                                Navigator.pop(context);

                                Metode.showErrorDialog(
                                  context: context,
                                  naslov: 'Došlo je do greške',
                                  button1Text: 'Zatvori',
                                  button1Fun: () {
                                    Navigator.pop(context);
                                  },
                                  isButton2: false,
                                );
                              }
                            },
                            isButton2: true,
                            button2Text: 'Otkaži',
                            button2Fun: () {
                              Navigator.pop(context);
                            },
                          );
                        },
                        child: SvgPicture.asset(
                          args!['userRating'] >= 4 ? 'assets/icons/trueStar.svg' : 'assets/icons/falseStar.svg',
                          height: 34,
                          width: 34,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Metode.showErrorDialog(
                            context: context,
                            naslov: 'Da li želite da ocijenite ovaj recept sa 5 zvjezdica?',
                            button1Text: 'Potvrdi',
                            button1Fun: () async {
                              try {
                                final internetTest = await InternetAddress.lookup('google.com');
                              } catch (error) {
                                Navigator.pop(context);

                                Metode.showErrorDialog(
                                  message: "Došlo je do greške sa internetom. Provjerite svoju konekciju.",
                                  context: context,
                                  naslov: 'Greška',
                                  button1Text: 'Zatvori',
                                  button1Fun: () => {Navigator.pop(context)},
                                  isButton2: false,
                                );
                                return;
                              }
                              try {
                                FirebaseFirestore.instance.collection('recepti').doc(args!['receptId']).set(
                                  {
                                    'ratings': {
                                      FirebaseAuth.instance.currentUser!.uid: 5,
                                    },
                                  },
                                  SetOptions(merge: true),
                                ).then((value) {
                                  setState(() {
                                    args!['userRating'] = 5;
                                    Navigator.pop(context);
                                  });
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Vaša ocjena je zabilježena.',
                                        style: Theme.of(context).textTheme.headline4,
                                      ),
                                      duration: const Duration(milliseconds: 1500),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Theme.of(context).colorScheme.secondary,
                                      elevation: 4,
                                    ),
                                  );
                                });
                              } catch (e) {
                                Navigator.pop(context);
                                Metode.showErrorDialog(
                                  context: context,
                                  naslov: 'Došlo je do greške',
                                  button1Text: 'Zatvori',
                                  button1Fun: () {
                                    Navigator.pop(context);
                                  },
                                  isButton2: false,
                                );
                              }
                            },
                            isButton2: true,
                            button2Text: 'Otkaži',
                            button2Fun: () {
                              Navigator.pop(context);
                            },
                          );
                        },
                        child: SvgPicture.asset(
                          args!['userRating'] == 5 ? 'assets/icons/trueStar.svg' : 'assets/icons/falseStar.svg',
                          height: 34,
                          width: 34,
                        ),
                      ),
                    ],
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
                          '${args!['opis']}',
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
                          itemCount: args!['sastojci'].length,
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
                                  Text(
                                    '${args!['sastojci'][index]}',
                                    style: Theme.of(context).textTheme.headline4,
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
                            itemCount: args!['koraci'].length,
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
                                        '${args!['koraci'][index]}',
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

                      final user = usersDocs.where((element) => element.id == args!['userId']).toList();

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
                      // TODO: DODATI INKWELL KOJI VODI DO PROFILVIEW PROFILA
                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Autor',
                              style: Theme.of(context).textTheme.headline2,
                            ),
                            const SizedBox(height: 5),
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
                                Text(
                                  '${user[0].data()['userName']}',
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                              ],
                            ),
                          ],
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
