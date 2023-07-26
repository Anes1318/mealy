import 'package:flutter/material.dart';
import 'package:mealy/components/Button.dart';
import 'package:mealy/components/InputField.dart';

class ForgotPassScreen extends StatefulWidget {
  static const String routeName = '/ForgotPassScreen';

  const ForgotPassScreen({super.key});

  @override
  State<ForgotPassScreen> createState() => _ForgotPassScreenState();
}

class _ForgotPassScreenState extends State<ForgotPassScreen> {
  @override
  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: medijakveri.size.width * 0.07),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Zaboravili ste šifru?',
                style: Theme.of(context).textTheme.headline1,
              ),
              const SizedBox(height: 110),
              InputField(
                isLabel: true,
                isMargin: true,
                visina: 20,
                medijakveri: medijakveri,
                label: 'Email',
                hintText: 'E-mail',
                inputAction: TextInputAction.done,
                inputType: TextInputType.emailAddress,
                obscureText: false,
                validator: (value) {},
                onSaved: (_) {},
              ),
              const SizedBox(height: 40),
              Button(
                isFullWidth: true,
                borderRadius: 20,
                visina: 18,
                funkcija: () {},
                buttonText: 'Pošalji zahtjev',
                backgroundColor: Theme.of(context).colorScheme.secondary,
                textColor: Theme.of(context).primaryColor,
                isBorder: true,
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Nazad na login',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
