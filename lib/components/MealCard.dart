import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mealy/screens/main/ReceptViewScreen.dart';

class MealCard extends StatelessWidget {
  final MediaQueryData medijakveri;
  final String naziv;
  final String opis;
  final String brOsoba;
  final String vrPripreme;
  final String tezina;
  final String imageUrl;
  final List<dynamic> ratings;
  final List<dynamic> sastojci;
  final List<dynamic> koraci;

  const MealCard({
    required this.medijakveri,
    required this.naziv,
    required this.opis,
    required this.brOsoba,
    required this.vrPripreme,
    required this.tezina,
    required this.imageUrl,
    required this.ratings,
    required this.sastojci,
    required this.koraci,
  });

  @override
  Widget build(BuildContext context) {
    double rating = 0;
    for (var element in ratings) {
      rating += element;
    }
    rating /= ratings.length;
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, ReceptViewScreen.routeName, arguments: {
          'naziv': naziv,
          'opis': opis,
          'brOsoba': brOsoba,
          'vrPripreme': vrPripreme,
          'tezina': tezina,
          'imageUrl': imageUrl,
          'ratings': ratings,
          'sastojci': sastojci,
          'koraci': koraci,
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
                  imageUrl,
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
                        width: medijakveri.size.width * 0.5, // da bi row uzeo sto vise mesta i razdvojio naziv i srce
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              constraints: BoxConstraints(maxWidth: medijakveri.size.width * 0.43),
                              child: FittedBox(
                                child: Text(
                                  naziv,
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                print('PITE');
                              },
                              child: Icon(
                                Iconsax.heart,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: medijakveri.size.width * 0.4,
                        child: Text(
                          opis.length > 60 ? opis.substring(1, 60) : opis,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: medijakveri.size.width * 0.5,
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
                              '$vrPripreme min',
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
                              'assets/icons/${tezina}Unselected.svg',
                              width: 19,
                              height: 19,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              tezina == 'Tesko' ? 'Teško' : tezina,
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
