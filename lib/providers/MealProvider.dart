import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../components/metode.dart';

class MealProvider with ChangeNotifier {
  Stream<QuerySnapshot<Map<String, dynamic>>>? _meals;
  DocumentSnapshot<Map<String, dynamic>>? _singleMeal;
  DocumentSnapshot<Map<String, dynamic>>? _user;
  double? tastaturaHeight = 0;

  bool? _isInternet = true;

  void setIsInternet(value) {
    _isInternet = value;
    notifyListeners();
  }

  bool get getIsInternet {
    return _isInternet!;
  }

  void readMeals() {
    _meals = FirebaseFirestore.instance.collection('recepti').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get meals {
    return _meals!;
  }

  Future<void> readSingleMeal(mealId) async {
    _singleMeal = await FirebaseFirestore.instance.collection('recepti').doc(mealId).get();
  }

  DocumentSnapshot<Map<String, dynamic>> get singleMeal {
    return _singleMeal!;
  }

  Future<void> readUser(userId) async {
    _user = await FirebaseFirestore.instance.collection('users').doc(userId).get();
  }

  DocumentSnapshot<Map<String, dynamic>> get user {
    return _user!;
  }

  void favMeal(Map<String, dynamic> mealFavorites, String mealId) async {
    bool isFav = false;
    mealFavorites.keys.forEach((element) async {
      if (element == FirebaseAuth.instance.currentUser!.uid) {
        isFav = true;
      }
    });
    if (isFav) {
      await FirebaseFirestore.instance.collection('recepti').doc(mealId).update({
        'favorites.${FirebaseAuth.instance.currentUser!.uid}': FieldValue.delete(),
      });
      notifyListeners();
    } else {
      await FirebaseFirestore.instance.collection('recepti').doc(mealId).update({
        'favorites': {
          FirebaseAuth.instance.currentUser!.uid: DateTime.now().toIso8601String(),
        },
      });
      notifyListeners();
    }
    notifyListeners();
  }

  void rateMeal(context, mealId, brZvjezdica) {
    Metode.showErrorDialog(
      isJednoPoredDrugog: true,
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
      button1Text: 'Otkaži',
      isButton1Icon: true,
      button1Icon: Icon(
        Iconsax.close_circle,
        color: Theme.of(context).colorScheme.primary,
      ),
      button1Fun: () {
        Navigator.pop(context);
      },
      isButton2: true,
      button2Text: 'Potvrdi',
      isButton2Icon: true,
      button2Icon: Icon(
        Iconsax.tick_circle,
        color: Theme.of(context).colorScheme.primary,
      ),
      button2Fun: () async {
        try {
          await InternetAddress.lookup('google.com');
        } catch (error) {
          Navigator.pop(context);

          Metode.showErrorDialog(
            isJednoPoredDrugog: false,
            message: "Došlo je do greške sa internetom. Provjerite svoju konekciju.",
            context: context,
            naslov: 'Greška',
            button1Text: 'Zatvori',
            button1Fun: () => Navigator.pop(context),
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
            isJednoPoredDrugog: false,
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
    );
    notifyListeners();
  }

  void removeRateMeal(context, mealId) {
    Metode.showErrorDialog(
      isJednoPoredDrugog: true,
      context: context,
      naslov: 'Da li ste sigurni da želite da uklonite Vašu ocjenu?',
      button1Text: 'Otkaži',
      isButton1Icon: true,
      button1Icon: Icon(
        Iconsax.close_circle,
        color: Theme.of(context).colorScheme.primary,
      ),
      button1Fun: () {
        Navigator.pop(context);
      },
      isButton2: true,
      button2Text: 'Potvrdi',
      isButton2Icon: true,
      button2Icon: Icon(
        Iconsax.tick_circle,
        color: Theme.of(context).colorScheme.primary,
      ),
      button2Fun: () async {
        try {
          await InternetAddress.lookup('google.com');
        } catch (error) {
          Navigator.pop(context);

          Metode.showErrorDialog(
            isJednoPoredDrugog: false,
            message: "Došlo je do greške sa internetom. Provjerite svoju konekciju.",
            context: context,
            naslov: 'Greška',
            button1Text: 'Zatvori',
            button1Fun: () => Navigator.pop(context),
            isButton2: false,
          );
          return;
        }
        try {
          FirebaseFirestore.instance.collection('recepti').doc(mealId).update(
            {
              'ratings.${FirebaseAuth.instance.currentUser!.uid}': FieldValue.delete(),
            },
          ).then((value) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Vaša ocjena je uklonjena.',
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
            isJednoPoredDrugog: false,
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
    );
    notifyListeners();
  }
}
