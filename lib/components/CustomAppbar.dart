import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CustomAppBar extends StatelessWidget {
  final String pageTitle;
  final IconData? prvaIkonica;
  final double? prvaIkonicaSize;
  final Function? funkcija;
  final IconData? drugaIkonica;
  final Function? funkcija2;
  final bool isCenter;

  const CustomAppBar({
    required this.pageTitle,
    this.prvaIkonica,
    this.prvaIkonicaSize,
    this.funkcija,
    this.drugaIkonica,
    this.funkcija2,
    required this.isCenter,
  });

  @override
  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);
    return isCenter
        ? SafeArea(
            child: Container(
              padding: EdgeInsets.only(top: (medijakveri.size.height - medijakveri.padding.top) * 0.035),
              margin: EdgeInsets.symmetric(horizontal: medijakveri.size.width * 0.07),
              height: (medijakveri.size.height - medijakveri.padding.top) * 0.035 + 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => funkcija!(),
                        icon: Icon(
                          prvaIkonica,
                          size: prvaIkonicaSize,
                        ),
                      ),
                      SizedBox(width: 5),
                    ],
                  ),
                  Text(
                    pageTitle,
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  IconButton(
                    onPressed: () => funkcija2!(),
                    icon: Icon(
                      drugaIkonica,
                      size: 34,
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container(
            padding: EdgeInsets.only(top: (medijakveri.size.height - medijakveri.padding.top) * 0.07),

            // height: (medijakveri.size.height - medijakveri.padding.top) * 0.035 + 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (prvaIkonica != null)
                      SizedBox(
                        height: 30,
                        width: 25,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => funkcija!(),
                          icon: Icon(
                            prvaIkonica,
                            size: prvaIkonicaSize,
                          ),
                        ),
                      ),
                    if (prvaIkonica != null) SizedBox(width: 5),
                    Text(
                      pageTitle,
                      style: Theme.of(context).textTheme.headline2,
                    ),
                  ],
                ),
                if (drugaIkonica != null)
                  InkWell(
                    onTap: () => funkcija2!(),
                    child: Icon(
                      drugaIkonica,
                      size: 34,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
              ],
            ),
          );
  }
}
