import 'package:flutter/material.dart';

class AccountViewScreen extends StatelessWidget {
  static const String routeName = '/AccountViewScreen';
  const AccountViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text('ANES'),
          ],
        ),
      ),
    );
  }
}
