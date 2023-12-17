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
  final String createdAt;
  final Map<String, dynamic> ratings;
  final List<dynamic> sastojci;
  final List<dynamic> koraci;
  final Map<String, dynamic> favorites;
  final List<dynamic> tagovi;
  bool? isAutorClick;

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
    required this.createdAt,
    this.isAutorClick = true,
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
    isFav = false;
    for (var element in widget.favorites.keys) {
      if (element == FirebaseAuth.instance.currentUser!.uid) {
        isFav = true;
      }
    }
    void favMeal() async {
      try {
        final internetTest = await InternetAddress.lookup('google.com');
      } catch (error) {
        Metode.showErrorDialog(
          isJednoPoredDrugog: false,
          message: "Došlo je do greške sa lom. Provjerite svoju konekciju.",
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
      try {
        Provider.of<MealProvider>(context, listen: false).favMeal(widget.favorites, widget.receptId);
      } catch (e) {
        Metode.showErrorDialog(
          context: context,
          naslov: 'Greška',
          message: Metode.getMessageFromErrorCode(e),
          button1Text: 'Zatvori',
          button1Fun: () => Navigator.pop(context),
          isButton2: false,
          isJednoPoredDrugog: false,
        );
      }
    }

    return GestureDetector(
      onTap: () {
        print(widget.imageUrl);
        return;
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
              createdAt: widget.createdAt,
              isAutorClick: widget.isAutorClick,
            ),
          ),
        );
      },
      child: Container(
        height: (widget.medijakveri.size.height - widget.medijakveri.padding.top) * 0.165,
        // height: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          margin: const EdgeInsets.only(left: 15, top: 15, bottom: 15, right: 5),
          child: Row(
            children: [
              // widget.imageUrl == null ?
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  widget.imageUrl,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
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
                        width: widget.medijakveri.size.width * 0.505, // da bi row uzeo sto vise mesta i razdvojio naziv i srce
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: widget.medijakveri.size.width * 0.425,
                                maxHeight: 23,
                              ),
                              child: FittedBox(
                                child: Text(
                                  widget.naziv,
                                  style: Theme.of(context).textTheme.headline3!.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                            Navigator.pop(context);

                                            await FirebaseFirestore.instance.collection('recepti').doc(widget.receptId).delete().then((value) {});
                                            await FirebaseStorage.instance.ref().child('receptImages').child('${widget.receptId}.jpg').delete();
                                          } catch (e) {
                                            Metode.showErrorDialog(
                                              isJednoPoredDrugog: false,
                                              message: Metode.getMessageFromErrorCode(e),
                                              context: context,
                                              naslov: 'Greška',
                                              button1Text: 'Zatvori',
                                              button1Fun: () => Navigator.pop(context),
                                              isButton2: false,
                                            );
                                          }
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
                        width: widget.medijakveri.size.width * 0.45,
                        child: Text(
                          widget.opis.length > 85 ? '${widget.opis.substring(0, 85)}...' : widget.opis,
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
                              rating.isNaN ? '0.0' : rating.toStringAsFixed(1),
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
