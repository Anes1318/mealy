import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mealy/screens/main/DodajScreen.dart';
import 'package:mealy/screens/main/NalogScreen.dart';
import 'package:mealy/screens/main/OmiljeniScreen.dart';
import 'package:mealy/screens/main/PocetnaScreen.dart';

class BottomNavigationBarScreen extends StatefulWidget {
  static const String routeName = '/BottomNavigationBarScreen';

  const BottomNavigationBarScreen({super.key});

  @override
  State<BottomNavigationBarScreen> createState() => _BottomNavigationBarScreenState();
}

class _BottomNavigationBarScreenState extends State<BottomNavigationBarScreen> {
  @override
  final List<Widget> _pages = [
    PocetnaScreen(),
    DodajScreen(),
    OmiljeniScreen(),
    NalogScreen(),
  ];

  int _selectedIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: medijakveri.size.width * 0.07),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
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
          items: [
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
