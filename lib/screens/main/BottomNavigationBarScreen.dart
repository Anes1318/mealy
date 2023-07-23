import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mealy/screens/main/AddScreen.dart';
import 'package:mealy/screens/main/AccountScreen.dart';
import 'package:mealy/screens/main/FavoriteScreen.dart';
import 'package:mealy/screens/main/HomeScreen.dart';
import 'package:provider/provider.dart';
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

  void _selectPage(int index) {
    Provider.of<MealProvider>(context, listen: false).readMeals();
    Provider.of<MealProvider>(context, listen: false).readUser(FirebaseAuth.instance.currentUser!.uid);

    setState(() {
      FocusManager.instance.primaryFocus?.unfocus();

      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
        height: 88,
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
