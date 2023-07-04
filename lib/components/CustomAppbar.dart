import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String pageTitle;
  final IconData? prvaIkonica;
  final double? prvaIkonicaSize;
  final Function? prvaIkonicaFunkcija;
  final IconData? drugaIkonica;
  final double? drugaIkonicaSize;
  final Function? drugaIkonicaFunkcija;
  final bool isCenter;

  CustomAppBar({
    required this.pageTitle,
    this.prvaIkonica,
    this.prvaIkonicaSize,
    this.prvaIkonicaFunkcija,
    this.drugaIkonica,
    this.drugaIkonicaSize,
    this.drugaIkonicaFunkcija,
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
                  InkWell(
                    onTap: () => prvaIkonicaFunkcija!(),
                    child: Icon(
                      prvaIkonica,
                      size: prvaIkonicaSize ?? 34,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: medijakveri.size.width * 0.65,
                    ),
                    child: FittedBox(
                      child: Text(
                        pageTitle,
                        style: Theme.of(context).textTheme.headline2,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => drugaIkonicaFunkcija!(),
                    child: Icon(
                      drugaIkonica,
                      size: drugaIkonicaSize ?? 34,
                      color: Theme.of(context).colorScheme.primary,
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
                          onPressed: () => prvaIkonicaFunkcija!(),
                          icon: Icon(
                            prvaIkonica,
                            size: prvaIkonicaSize,
                            color: Theme.of(context).colorScheme.primary,
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
                    onTap: () => drugaIkonicaFunkcija!(),
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
