import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mealy/screens/main/ReceptViewScreen.dart';

class MealCard extends StatefulWidget {
  final MediaQueryData medijakveri;
  final String userId;
  final String receptId;
  final String naziv;
  final String opis;
  final String brOsoba;
  final String vrPripreme;
  final String tezina;
  final String imageUrl;
  final List<dynamic> ratings;
  final List<dynamic> sastojci;
  final List<dynamic> koraci;
  final List<dynamic> favorites;

  const MealCard({
    required this.medijakveri,
    required this.userId,
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
  });

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> {
  @override
  bool isFav = false;
  double rating = 0;
  Widget build(BuildContext context) {
    for (var element in widget.ratings) {
      rating += element;
    }
    rating /= widget.ratings.length;

    for (var element in widget.favorites) {
      element == FirebaseAuth.instance.currentUser!.uid;
      isFav = true;
    }
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, ReceptViewScreen.routeName, arguments: {
          'naziv': widget.naziv,
          'opis': widget.opis,
          'brOsoba': widget.brOsoba,
          'vrPripreme': widget.vrPripreme,
          'tezina': widget.tezina,
          'imageUrl': widget.imageUrl,
          'ratings': widget.ratings,
          'sastojci': widget.sastojci,
          'koraci': widget.koraci,
          'userId': widget.userId,
          'receptId': widget.receptId,
          'isFav': isFav,
        });
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
                  fit: BoxFit.fill,
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
                            GestureDetector(
                              onTap: () async {
                                if (isFav) {
                                  await FirebaseFirestore.instance.collection('recepti').doc(widget.receptId).update({
                                    'favorites': FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
                                  }).then((value) {
                                    setState(() {
                                      isFav = false;
                                    });
                                  });
                                  return;
                                }

                                await FirebaseFirestore.instance.collection('recepti').doc(widget.receptId).update({
                                  'favorites': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
                                }).then((value) {
                                  setState(() {
                                    isFav = true;
                                  });
                                });
                              },
                              child: SvgPicture.asset('assets/icons/${isFav}Heart.svg'),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: widget.medijakveri.size.width * 0.4,
                        child: Text(
                          widget.opis.length > 60 ? widget.opis.substring(1, 60) : widget.opis,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: widget.medijakveri.size.width * 0.5,
                    // width: 150,
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
                              '$rating',
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
