import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../components/CustomAppbar.dart';
import '../../components/MealCard.dart';

class OmiljeniScreen extends StatefulWidget {
  static const String routeName = '/OmiljeniScreen';

  const OmiljeniScreen({super.key});

  @override
  State<OmiljeniScreen> createState() => _OmiljeniScreenState();
}

class _OmiljeniScreenState extends State<OmiljeniScreen> {
  @override
  List<TextEditingController> _textControllers = [];

  @override
  void dispose() {
    for (var controller in _textControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addTextField() {
    setState(() {
      _textControllers.add(TextEditingController());
    });
  }

  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);
    final recepti = FirebaseFirestore.instance.collection('recepti').get();

    return SingleChildScrollView(
      child: Column(
        children: [
          CustomAppBar(pageTitle: 'Omiljeni', isCenter: false),
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
              List<dynamic> favRecepti = [];

              receptDocs.forEach((element) {
                List<dynamic> listaUsera = (element.data()['favorites'].map((item) => item as String)?.toList());
                if (listaUsera.contains(FirebaseAuth.instance.currentUser!.uid)) {
                  favRecepti.add(element);
                }
              });
              print(favRecepti);

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
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  separatorBuilder: ((context, index) => const SizedBox(height: 15)),
                  itemCount: receptDocs.length,
                  itemBuilder: (context, index) => MealCard(
                    medijakveri: medijakveri,
                    receptId: receptDocs[index].id,
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
                    favorites: receptDocs[index].data()['favorites'],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
