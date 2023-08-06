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
  final int? brMinLinija;
  final int? brMaxLinija;
  final double borderRadijus;
  final double sirina;
  final double visina;
  final FocusNode? focusNode;
  final bool isMargin;
  final bool? isFixedWidth;
  final double? fixedWidth;
  final TextEditingController? controller;
  final double? hintTextSize;
  final TextStyle? errorStyle;
  final TextCapitalization? kapitulacija;
  final List<TextInputFormatter>? textInputFormater;
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
    this.brMinLinija = 1,
    this.brMaxLinija = 1,
    this.borderRadijus = 20,
    this.sirina = 1,
    this.visina = 10,
    this.controller,
    required this.isMargin,
    this.hintTextSize,
    this.errorStyle,
    this.kapitulacija,
    this.isFixedWidth,
    this.fixedWidth,
    this.textInputFormater,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFixedWidth == null ? medijakveri.size.width * sirina : fixedWidth,
      margin: isMargin ? EdgeInsets.only(bottom: (medijakveri.size.height - medijakveri.padding.top) * 0.025) : EdgeInsets.zero,
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
            inputFormatters: textInputFormater,
            onFieldSubmitted: onFieldSubmitted,
            initialValue: initalValue,
            textCapitalization: kapitulacija ?? TextCapitalization.none,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              errorMaxLines: 2,
              errorStyle: errorStyle,
              contentPadding: EdgeInsets.only(left: 15, bottom: visina, top: visina),
              hintText: hintText,
              hintStyle: Theme.of(context).textTheme.headline4?.copyWith(
                    color: Colors.grey,
                    fontSize: hintTextSize ?? 16,
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
            minLines: brMinLinija,
            maxLines: brMaxLinija,
          ),
        ],
      ),
    );
  }
}
