import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  static const String routeName = '/ChangePasswordScreen';

  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
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
