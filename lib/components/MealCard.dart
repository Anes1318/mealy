import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';

class MealCard extends StatelessWidget {
  final MediaQueryData medijakveri;
  final String ime;
  final String opis;
  final String brOsoba;
  final String vrPripreme;
  final String tezina;
  final String imageUrl;

  const MealCard({
    required this.medijakveri,
    required this.ime,
    required this.opis,
    required this.brOsoba,
    required this.vrPripreme,
    required this.tezina,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
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
              child: Image.network(
                imageUrl,
                height: 100,
                width: 100,
              ),
              borderRadius: BorderRadius.circular(20),
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
                          Text(
                            ime,
                            style: Theme.of(context).textTheme.headline3,
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
                            '5.0',
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
    );
  }
}
