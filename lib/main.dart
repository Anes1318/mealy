import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// screens
import 'package:mealy/screens/auth/DobrodosliScreen.dart';
import 'package:mealy/screens/auth/ForgotPassScreen.dart';
import 'package:mealy/screens/auth/LoginScreen.dart';
import 'package:mealy/screens/auth/RegisterScreen.dart';
import 'package:mealy/screens/main/BottomNavigationBarScreen.dart';
import 'package:mealy/screens/main/DodajScreen.dart';
import 'package:mealy/screens/main/NalogScreen.dart';
import 'package:mealy/screens/main/OmiljeniScreen.dart';
import 'package:mealy/screens/main/PocetnaScreen.dart';

// components

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    webRecaptchaSiteKey: 'recaptcha-v3-site-key',
    // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Safety Net provider
    // 3. Play Integrity provider
    androidProvider: AndroidProvider.debug,
    // Default provider for iOS/macOS is the Device Check provider. You can use the "AppleProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Device Check provider
    // 3. App Attest provider
    // 4. App Attest provider with fallback to Device Check provider (App Attest provider is only available on iOS 14.0+, macOS 14.0+)
    appleProvider: AppleProvider.appAttest,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFFFEEEE),
          primaryColor: const Color(0xFF331618),
          colorScheme: ThemeData().colorScheme.copyWith(
                primary: const Color(0xFF331618), // da bi suffix ikonica i border input polja(u search baru) promijenila boju kad je focused
                secondary: const Color(0xFFFDC7C7),
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
          LoginScreen.routeName: (context) => LoginScreen(),
          RegisterScreen.routeName: (context) => RegisterScreen(),
          ForgotPassScreen.routeName: (context) => ForgotPassScreen(),
          BottomNavigationBarScreen.routeName: (context) => BottomNavigationBarScreen(),
          PocetnaScreen.routeName: (context) => PocetnaScreen(),
          DodajScreen.routeName: (context) => DodajScreen(),
          OmiljeniScreen.routeName: (context) => OmiljeniScreen(),
          NalogScreen.routeName: (context) => NalogScreen(),
        },
        home: snapshot.data == null ? DobrodosliScreen() : BottomNavigationBarScreen(),
      ),
    );
  }
}
