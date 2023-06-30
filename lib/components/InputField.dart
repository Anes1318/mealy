import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatelessWidget {
  final MediaQueryData medijakveri;
  final String? label;
  final bool? isLabel;
  final String? hintText;
  final String? initalValue;
  final TextInputAction inputAction;
  final TextInputType inputType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Function(String?)? onSaved;
  final Function(String?)? onChanged;
  final Function(String?)? onFieldSubmitted;
  final int? brLinija;
  final double borderRadijus;
  final double sirina;
  final double visina;
  final FocusNode? focusNode;
  final bool isPadding;
  final TextEditingController? controller;
  const InputField({
    required this.medijakveri,
    this.label,
    this.isLabel = false,
    required this.hintText,
    this.initalValue,
    this.focusNode,
    required this.inputAction,
    required this.inputType,
    required this.obscureText,
    required this.validator,
    required this.onSaved,
    this.onFieldSubmitted,
    this.onChanged,
    this.brLinija = 1,
    this.borderRadijus = 20,
    this.sirina = 1,
    this.visina = 10,
    this.controller,
    required this.isPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: medijakveri.size.width * sirina,
      margin: isPadding ? EdgeInsets.only(bottom: (medijakveri.size.height - medijakveri.padding.top) * 0.025) : EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLabel!)
            Container(
              margin: EdgeInsets.only(
                bottom: 8,
                left: medijakveri.size.width * 0.02,
              ),
              child: Text(
                label!,
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          TextFormField(
            keyboardType: inputType,
            textInputAction: inputAction,
            obscureText: obscureText,
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            validator: validator,
            onSaved: onSaved,
            onFieldSubmitted: onFieldSubmitted,
            initialValue: initalValue,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: visina),
              hintText: hintText,
              hintStyle: Theme.of(context).textTheme.headline4?.copyWith(
                    color: Colors.grey,
                  ),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(borderRadijus),
              ),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(borderRadijus),
              ),
            ),
            minLines: brLinija,
            maxLines: brLinija,
          ),
        ],
      ),
    );
  }
}
