import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mealy/providers/MealProvider.dart';
import 'package:mealy/screens/meal/MealEditScreen.dart';
import 'package:mealy/screens/meal/MealViewScreen.dart';
import 'package:provider/provider.dart';

import '../screens/main/BottomNavigationBarScreen.dart';
import 'metode.dart';

class MealCard extends StatefulWidget {
  final MediaQueryData medijakveri;
  final String autorId;
  final String receptId;
  final String naziv;
  final String opis;
  final String brOsoba;
  final String vrPripreme;
  final String tezina;
  final String imageUrl;
  final Map<String, dynamic> ratings;
  final List<dynamic> sastojci;
  final List<dynamic> koraci;
  final List<dynamic> favorites;
  final List<dynamic> tagovi;

  MealCard({
    required this.medijakveri,
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
  });

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> {
  bool isFav = false;

  @override
  Widget build(BuildContext context) {
    double rating = 0;
    if (widget.ratings.values.isNotEmpty) {
      for (var item in widget.ratings.values) {
        rating += item;
      }
    }
    rating /= widget.ratings.length;

    for (var element in widget.favorites) {
      if (element == FirebaseAuth.instance.currentUser!.uid) {
        isFav = true;
      }
    }
    void favMeal() async {
      try {
        final internetTest = await InternetAddress.lookup('google.com');
      } catch (error) {
        Metode.showErrorDialog(
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
      Provider.of<MealProvider>(context, listen: false).favMeal(widget.favorites, widget.receptId);
    }

    return GestureDetector(
      onTap: () {
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
            pageBuilder: (context, animation, duration) => MealViewScreen(
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
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          margin: const EdgeInsets.only(left: 15, top: 15, bottom: 15, right: 5),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  widget.imageUrl,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                  // scale: 0.3,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: widget.medijakveri.size.width * 0.5, // da bi row uzeo sto vise mesta i razdvojio naziv i srce
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              constraints: BoxConstraints(maxWidth: widget.medijakveri.size.width * 0.43),
                              child: FittedBox(
                                child: Text(
                                  widget.naziv,
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                              ),
                            ),
                            widget.autorId != FirebaseAuth.instance.currentUser!.uid
                                ? GestureDetector(
                                    onTap: () => favMeal(),
                                    child: SvgPicture.asset(
                                      'assets/icons/${isFav}Heart.svg',
                                      height: 24,
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      Metode.showErrorDialog(
                                        context: context,
                                        naslov: 'Koju akciju želite da izvršite',
                                        button1Text: 'Izmijenite recept',
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
                                        button2Fun: () async {
                                          await FirebaseFirestore.instance.collection('recepti').doc(widget.receptId).delete();
                                          await FirebaseStorage.instance.ref().child('receptImages').child('${widget.receptId}.jpg').delete();
                                          Navigator.pop(context);
                                          Navigator.pushReplacementNamed(context, BottomNavigationBarScreen.routeName);
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(3),
                                      child: SvgPicture.asset(
                                        'assets/icons/more.svg',
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      Container(
                        width: widget.medijakveri.size.width * 0.4,
                        child: Text(
                          widget.opis.length > 85 ? '${widget.opis.substring(1, 85)}...' : widget.opis,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: widget.medijakveri.size.width * 0.5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Iconsax.clock,
                              size: 19,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${widget.vrPripreme} min',
                              style: Theme.of(context).textTheme.headline5,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Iconsax.star,
                              size: 19,
                              color: Theme.of(context).primaryColor,
                            ),
                            SizedBox(width: 3),
                            Text(
                              rating.isNaN ? '0.0' : '$rating',
                              style: Theme.of(context).textTheme.headline5,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/${widget.tezina}Unselected.svg',
                              width: 19,
                              height: 19,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              widget.tezina == 'Tesko' ? 'Teško' : widget.tezina,
                              style: Theme.of(context).textTheme.headline5,
                            ),
                          ],
                        ),
                      ],
                    ),
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
