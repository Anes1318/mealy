import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Metode {
  static void showErrorDialog({required String message, required BuildContext context, required String naslov, required String button1Text, String? button2Text, required Function button1Fun, Function? button2Fun, required bool isButton2}) {
    showDialog(
      context: context,
      builder: (context) {
        final medijakveri = MediaQuery.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          title: Text(
            naslov,
            textAlign: TextAlign.center,
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 18.0, bottom: 24),
            child: Text(
              message,
              style: TextStyle(fontSize: 20, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            InkWell(
              onTap: () => button1Fun(),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: medijakveri.size.height * 0.01,
                ),
                margin: EdgeInsets.symmetric(
                  horizontal: medijakveri.size.width * 0.2,
                  vertical: medijakveri.size.height * 0.01,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    button1Text,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            if (isButton2)
              InkWell(
                onTap: () => button2Fun!(),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: medijakveri.size.height * 0.01,
                  ),
                  margin: EdgeInsets.symmetric(
                    horizontal: medijakveri.size.width * 0.2,
                    vertical: medijakveri.size.height * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      button2Text!,
                      style: TextStyle(
                        //fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  static String getMessageFromErrorCode(error) {
    switch (error.code) {
      case "ERROR_EMAIL_ALREADY_IN_USE":
      case "account-exists-with-different-credential":
      case "email-already-in-use":
        return "Taj E-mail je već u upotrebi.";

      case "network-request-failed":
        return "Nema internet konekcije";
      case "ERROR_WRONG_PASSWORD":
      case "wrong-password":
        return "Pogrešna šifra";
      case "ERROR_USER_NOT_FOUND":
      case "user-not-found":
        return "Ne možemo naći korisnika sa tim E-mailom.";
      case "ERROR_USER_DISABLED":
      case "user-disabled":
        return "User disabled.";
      case "ERROR_TOO_MANY_REQUESTS":
      case "operation-not-allowed":
        return "Too many requests to log into this account.";
      case "ERROR_OPERATION_NOT_ALLOWED":
      case "operation-not-allowed":
        return "Server error, please try again later.";
      case "ERROR_INVALID_EMAIL":
      case "invalid-email":
        return "Molimo Vas unesite validnu E-mail adresu.";
      default:
        return "Došlo je do greške. Molimo Vas pokušajte kasnije.";
    }
  }

  // static String? stavke(int kolicina) {
  //   if (kolicina % 10 == 1 && kolicina != 11) {
  //     return 'stavka';
  //   } else if ((kolicina % 10 <= 4 && (kolicina % 100 != 12 && kolicina % 100 != 13 && kolicina % 100 != 14) && kolicina != 0)) {
  //     return 'stavke';
  //   } else {
  //     return 'stavki';
  //   }
  // }

  // static Future<String?> stavke2(Future<int> kolicina) async {
  //   int kolicinaValue = await kolicina;
  //   if (kolicinaValue % 10 == 1 && kolicinaValue != 11) {
  //     return 'stavka';
  //   } else if (kolicinaValue % 10 <= 4 && (kolicinaValue % 100 != 12 && kolicinaValue % 100 != 13 && kolicinaValue % 100 != 14)) {
  //     return 'stavke';
  //   } else {
  //     return 'stavki';
  //   }
  // }
}
