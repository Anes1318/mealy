import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';

class MealCard extends StatelessWidget {
  final MediaQueryData medijakveri;
  final String tezina;
  const MealCard({required this.medijakveri, required this.tezina});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: medijakveri.size.width,
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Container(
                      width: medijakveri.size.width * 0.5, // da bi row uzeo sto vise mesta i razdvojio naziv i srce
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Naziv',
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
                      width: medijakveri.size.width * 0.5,
                      child: Text(
                        'Go back to where it all began with the classic ccheese and tomato base......aldfkjalsdkfjsaldakfjladskfjldaskfjadlskfjasdlf...',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: medijakveri.size.width * 0.5,
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
                          SizedBox(width: 3),
                          Text(
                            '60 min',
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
                      Container(
                        width: 75,
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/${tezina}Unselected.svg',
                              width: 19,
                              height: 19,
                            ),
                            SizedBox(width: 3),
                            Text(
                              tezina,
                              style: Theme.of(context).textTheme.headline5,
                            ),
                          ],
                        ),
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
