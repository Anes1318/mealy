import 'package:cloud_firestore/cloud_firestore.dart';
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
    final recepti = FirebaseFirestore.instance.collection('recepti').get();
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            CustomAppBar(pageTitle: 'Početna', isCenter: false),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  child: Container(
                    width: medijakveri.size.width * 0.7,
                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        hintText: 'Potražite tag ili namirnicu...',
                        hintStyle: Theme.of(context).textTheme.headline4?.copyWith(
                              color: Colors.grey,
                            ),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        suffixIcon: const Icon(Iconsax.search_normal),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  child: Container(
                    padding: const EdgeInsets.all(10),
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
            const SizedBox(height: 10),
            FutureBuilder(
              future: recepti,
              builder: ((context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: (medijakveri.size.height - medijakveri.padding.top) * 0.7,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final receptDocs = snapshot.data!.docs;
                if (receptDocs.isEmpty) {
                  return Container(
                    height: (medijakveri.size.height - medijakveri.padding.top) * 0.7,
                    child: Center(
                      child: Text(
                        'Nema recepata',
                        style: Theme.of(context).textTheme.headline2,
                      ),
                    ),
                  );
                }

                return Container(
                  height: medijakveri.size.height * 0.7,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    separatorBuilder: ((context, index) => const SizedBox(height: 15)),
                    itemCount: receptDocs.length,
                    itemBuilder: (context, index) => MealCard(
                      medijakveri: medijakveri,
                      userId: receptDocs[index].data()['userId'],
                      naziv: receptDocs[index].data()['recept']['naziv'],
                      opis: receptDocs[index].data()['recept']['opis'],
                      brOsoba: receptDocs[index].data()['recept']['brOsoba'],
                      vrPripreme: receptDocs[index].data()['recept']['vrPripreme'],
                      tezina: receptDocs[index].data()['recept']['tezina'],
                      imageUrl: receptDocs[index].data()['imageUrl'],
                      ratings: receptDocs[index].data()['recept']['ratings'],
                      sastojci: receptDocs[index].data()['recept']['sastojci'],
                      koraci: receptDocs[index].data()['recept']['koraci'],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
