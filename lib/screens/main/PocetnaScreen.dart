import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mealy/components/CustomAppbar.dart';
import 'package:mealy/components/MealCard.dart';

class PocetnaScreen extends StatefulWidget {
  static const String routeName = '/PocetnaScreen';

  const PocetnaScreen({super.key});

  @override
  State<PocetnaScreen> createState() => _PocetnaScreenState();
}

class _PocetnaScreenState extends State<PocetnaScreen> {
  @override
  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);
    String tezina = 'Tesko';
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomAppBar(pageTitle: 'Početna', isCenter: false),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              child: Container(
                width: medijakveri.size.width * 0.7,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    hintText: 'Potražite tag ili namirnicu...',
                    hintStyle: Theme.of(context).textTheme.headline4?.copyWith(
                          color: Colors.grey,
                        ),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    suffixIcon: Icon(Iconsax.search_normal),
                  ),
                ),
              ),
            ),
            InkWell(
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Iconsax.filter_square,
                  color: Theme.of(context).primaryColor,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
        Container(
          height: (medijakveri.size.height - medijakveri.padding.top) * 0.7,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 15),
            itemCount: 6,
            separatorBuilder: ((context, index) => SizedBox(height: 15)),
            itemBuilder: (context, index) => MealCard(medijakveri: medijakveri, tezina: tezina),
          ),
        )
      ],
    );
  }
}
