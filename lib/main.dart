import 'package:flutter/material.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// screens
import 'package:mealy/screens/auth/WelcomeScreen.dart';
import 'package:mealy/screens/auth/ForgotPassScreen.dart';
import 'package:mealy/screens/auth/LoginScreen.dart';
import 'package:mealy/screens/auth/RegisterScreen.dart';
import 'package:mealy/screens/main/AccountScreen.dart';
import 'package:mealy/screens/main/BottomNavigationBarScreen.dart';
import 'package:mealy/screens/settings/SettingsScreen.dart';
import 'package:mealy/screens/account/AccountEditScreen.dart';

// providers
import 'providers/MealProvider.dart';

// components

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    webRecaptchaSiteKey: 'recaptcha-v3-site-key',
    androidProvider: AndroidProvider.debug,
  );
  Future.delayed(const Duration(milliseconds: 500), () {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => MealProvider(),
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        initialData: FirebaseAuth.instance.currentUser,
        builder: (context, snapshot) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: const Color(0xFFFFEEEE),
            primaryColor: const Color(0xFF331618),
            colorScheme: ThemeData().colorScheme.copyWith(
                  primary: const Color(0xFF331618), // da bi suffix ikonica i border input polja(u search baru) promijenila boju kad je focused
                  secondary: Color.fromRGBO(253, 199, 199, 1),
                  tertiary: const Color(0xFFDB6D6E),
                ),
            textTheme: const TextTheme(
              headline1: TextStyle(
                fontFamily: 'Cabin',
                fontSize: 36,
                color: Color(0xFF331618),
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
              headline2: TextStyle(
                fontFamily: 'Cabin',
                fontSize: 24,
                color: Color(0xFF331618),
              ),
              headline3: TextStyle(
                fontFamily: 'Cabin',
                fontSize: 20,
                color: Color(0xFF331618),
                letterSpacing: .7,
              ),
              headline4: TextStyle(
                fontFamily: 'Cabin',
                fontSize: 16,
                color: Color(0xFF331618),
                // letterSpacing: 0.1,
              ),
              headline5: TextStyle(
                fontFamily: 'Cabin',
                fontSize: 12,
                color: Color(0xFF331618),
              ),
            ),
          ),
          title: 'Mealy',
          routes: {
            LoginScreen.routeName: (context) => const LoginScreen(),
            RegisterScreen.routeName: (context) => const RegisterScreen(),
            ForgotPassScreen.routeName: (context) => const ForgotPassScreen(),
            BottomNavigationBarScreen.routeName: (context) => const BottomNavigationBarScreen(),
            SettingsScreen.routeName: (context) => const SettingsScreen(),
            AccountScreen.routeName: (context) => const AccountScreen(),
            AccountEditScreen.routeName: (context) => const AccountEditScreen(),
          },
          home: snapshot.data == null ? const WelcomeScreen() : const BottomNavigationBarScreen(),
        ),
      ),
    );
  }
}
