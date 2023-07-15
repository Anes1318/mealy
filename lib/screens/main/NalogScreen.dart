import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mealy/components/metode.dart';

import '../../components/CustomAppbar.dart';

class NalogScreen extends StatefulWidget {
  static const String routeName = '/NalogScreen';

  const NalogScreen({super.key});

  @override
  State<NalogScreen> createState() => _NalogScreenState();
}

class _NalogScreenState extends State<NalogScreen> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          CustomAppBar(pageTitle: 'Nalog', isCenter: false),
          isLoading == true
              ? const CircularProgressIndicator()
              : GestureDetector(
                  onTap: () async {
                    setState(() {
                      isLoading = true;
                    });
                    try {
                      await FirebaseAuth.instance.signOut().then((value) {
                        setState(() {
                          isLoading = false;
                        });
                        Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
                      });
                    } on FirebaseAuthException catch (error) {
                      setState(() {
                        isLoading = false;
                      });

                      Metode.showErrorDialog(
                        message: Metode.getMessageFromErrorCode(error),
                        context: context,
                        naslov: 'Greška',
                        button1Text: 'Zatvori',
                        button1Fun: () => {Navigator.pop(context)},
                        isButton2: false,
                      );
                    }
                  },
                  child: Text('SIGN OUT'),
                ),
        ],
      ),
    );
  }
}
