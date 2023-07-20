import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/metode.dart';

class MealProvider with ChangeNotifier {
  Future<QuerySnapshot<Map<String, dynamic>>>? _meals;
  DocumentSnapshot<Map<String, dynamic>>? _singleMeal;
  void readMeals() {
    _meals = FirebaseFirestore.instance.collection('recepti').get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> get meals {
    return _meals!;
  }

  Future<void> readSingleMeal(mealId) async {
    _singleMeal = await FirebaseFirestore.instance.collection('recepti').doc(mealId).get();
  }

  DocumentSnapshot<Map<String, dynamic>> get singleMeal {
    return _singleMeal!;
  }

  void favMeal(List<dynamic> mealFavorites, String mealId) async {
    bool isFav = false;
    mealFavorites.forEach((element) async {
      if (element == FirebaseAuth.instance.currentUser!.uid) {
        isFav = true;
      }
    });
    if (isFav) {
      await FirebaseFirestore.instance.collection('recepti').doc(mealId).update({
        'favorites': FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
      });
      notifyListeners();
    } else {
      await FirebaseFirestore.instance.collection('recepti').doc(mealId).update({
        'favorites': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
      });
      notifyListeners();
    }
    notifyListeners();
  }

  void rateMeal(context, mealId, brZvjezdica) {
    Metode.showErrorDialog(
      context: context,
      naslov: brZvjezdica == 1
          ? 'Da li želite da ocijenite ovaj recept sa 1 zvjezdicom?'
          : brZvjezdica == 2
              ? 'Da li želite da ocijenite ovaj recept sa 2 zvjezdice?'
              : brZvjezdica == 3
                  ? 'Da li želite da ocijenite ovaj recept sa 3 zvjezdicom?'
                  : brZvjezdica == 4
                      ? 'Da li želite da ocijenite ovaj recept sa 4 zvjezdicom?'
                      : brZvjezdica == 5
                          ? 'Da li želite da ocijenite ovaj recept sa 5 zvjezdicom?'
                          : '',
      button1Text: 'Potvrdi',
      button1Fun: () async {
        try {
          final internetTest = await InternetAddress.lookup('google.com');
        } catch (error) {
          Navigator.pop(context);

          Metode.showErrorDialog(
            message: "Došlo je do greške sa internetom. Provjerite svoju konekciju.",
            context: context,
            naslov: 'Greška',
            button1Text: 'Zatvori',
            button1Fun: () => {Navigator.pop(context)},
            isButton2: false,
          );
          return;
        }
        try {
          FirebaseFirestore.instance.collection('recepti').doc(mealId).set(
            {
              'ratings': {
                FirebaseAuth.instance.currentUser!.uid: brZvjezdica,
              },
            },
            SetOptions(merge: true),
          ).then((value) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Vaša ocjena je zabilježena.',
                  style: Theme.of(context).textTheme.headline4,
                ),
                duration: const Duration(milliseconds: 1500),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                elevation: 4,
              ),
            );
            notifyListeners();
          });
        } catch (e) {
          Navigator.pop(context);

          Metode.showErrorDialog(
            context: context,
            naslov: 'Došlo je do greške',
            button1Text: 'Zatvori',
            button1Fun: () {
              Navigator.pop(context);
            },
            isButton2: false,
          );
        }
      },
      isButton2: true,
      button2Text: 'Otkaži',
      button2Fun: () {
        Navigator.pop(context);
      },
    );
    notifyListeners();
  }
}
