import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mealy/components/metode.dart';
import 'package:mealy/screens/main/AddScreen.dart';
import 'package:mealy/screens/main/AccountScreen.dart';
import 'package:mealy/screens/main/FavoriteScreen.dart';
import 'package:mealy/screens/main/HomeScreen.dart';
import 'package:mealy/screens/meal/MealViewScreen.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:slide_indexed_stack/slide_indexed_stack.dart';

import '../../providers/MealProvider.dart';

class BottomNavigationBarScreen extends StatefulWidget {
  static const String routeName = '/BottomNavigationBarScreen';

  const BottomNavigationBarScreen({super.key});

  @override
  State<BottomNavigationBarScreen> createState() => _BottomNavigationBarScreenState();
}

class _BottomNavigationBarScreenState extends State<BottomNavigationBarScreen> {
  final List<Widget> _screens = [
    HomeScreen(),
    AddScreen(),
    FavoriteScreen(),
    AccountScreen(),
  ];

  int _selectedIndex = 0;

  void _selectPage(int index) async {
    if (index == _selectedIndex) {
      return;
    }
    setState(() {
      FocusManager.instance.primaryFocus?.unfocus();

      _selectedIndex = index;
    });
    try {
      await InternetAddress.lookup('google.com').then((value) {
        Provider.of<MealProvider>(context, listen: false).setIsInternet(true);
      });
    } catch (error) {
      Provider.of<MealProvider>(context, listen: false).setIsInternet(false);
    }
  }

  void initDyanmicLinks() async {
    FirebaseDynamicLinks link = FirebaseDynamicLinks.instance;

    await FirebaseDynamicLinks.instance.getInitialLink().then((value) async {
      if (value != null) {
        if (value.link.queryParameters['ref'] != null) {
          String receptId = value.link.queryParameters['ref']!;
          await Provider.of<MealProvider>(context, listen: false).readSingleMeal(receptId).then((value) {
            final linkMeal = Provider.of<MealProvider>(context, listen: false).singleMeal;
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 150),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
                pageBuilder: (context, animation, duration) => MealViewScreen(
                  naziv: linkMeal.data()!['naziv'],
                  opis: linkMeal.data()!['opis'],
                  brOsoba: linkMeal.data()!['brOsoba'],
                  vrPripreme: linkMeal.data()!['vrPripreme'],
                  tezina: linkMeal.data()!['tezina'],
                  imageUrl: linkMeal.data()!['imageUrl'],
                  ratings: linkMeal.data()!['ratings'],
                  sastojci: linkMeal.data()!['sastojci'],
                  koraci: linkMeal.data()!['koraci'],
                  autorId: linkMeal.data()!['userId'],
                  receptId: receptId,
                  favorites: linkMeal.data()!['favorites'],
                  tagovi: linkMeal.data()!['tagovi'],
                  createdAt: linkMeal.data()!['createdAt'],
                  isAutorClick: true,
                ),
              ),
            );
          });
        }
      }
    });
    link.onLink.listen((data) async {
      if (data.link.queryParameters['ref'] != null) {
        String receptId = data.link.queryParameters['ref']!;
        await Provider.of<MealProvider>(context, listen: false).readSingleMeal(receptId).then((value) {
          final linkMeal = Provider.of<MealProvider>(context, listen: false).singleMeal;
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 150),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
              pageBuilder: (context, animation, duration) => MealViewScreen(
                naziv: linkMeal.data()!['naziv'],
                opis: linkMeal.data()!['opis'],
                brOsoba: linkMeal.data()!['brOsoba'],
                vrPripreme: linkMeal.data()!['vrPripreme'],
                tezina: linkMeal.data()!['tezina'],
                imageUrl: linkMeal.data()!['imageUrl'],
                ratings: linkMeal.data()!['ratings'],
                sastojci: linkMeal.data()!['sastojci'],
                koraci: linkMeal.data()!['koraci'],
                autorId: linkMeal.data()!['userId'],
                receptId: receptId,
                favorites: linkMeal.data()!['favorites'],
                tagovi: linkMeal.data()!['tagovi'],
                createdAt: linkMeal.data()!['createdAt'],
                isAutorClick: true,
              ),
            ),
          );
        });
      }

      // Navigator.pushNamed(context, dynamicLinkData.link.path);
    }).onError((error) {
      print('onLink error');
      print(error.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);
    initDyanmicLinks();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: medijakveri.size.width * 0.07),
        child: SlideIndexedStack(
          axis: Axis.horizontal,
          slideOffset: 0.7,
          duration: const Duration(milliseconds: 200),
          index: _selectedIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              width: 0.3,
              color: Color.fromRGBO(176, 176, 176, 1),
            ),
          ),
        ),
        height: (medijakveri.size.height - medijakveri.padding.top) * 0.1,
        child: BottomNavigationBar(
          onTap: _selectPage,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          iconSize: 30,
          selectedLabelStyle: Theme.of(context).textTheme.headline5,
          unselectedLabelStyle: Theme.of(context).textTheme.headline5,
          selectedItemColor: Theme.of(context).colorScheme.tertiary,
          unselectedItemColor: Theme.of(context).primaryColor,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Iconsax.home_2),
              label: 'Početna',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.add_square),
              label: 'Dodaj',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.heart),
              label: 'Omiljeni',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.profile_circle),
              label: 'Nalog',
            ),
          ],
        ),
      ),
    );
  }
}
