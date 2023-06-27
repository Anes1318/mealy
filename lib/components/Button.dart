import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String buttonText;
  final Color? color, textColor;
  final bool isBorder;
  final double visina;
  final double? fontsize;
  final double? sirina;
  double? horizontalMargin = 0;
  final double borderRadius;
  final Function funkcija;

  Button({
    required this.borderRadius,
    this.fontsize,
    required this.visina,
    this.sirina,
    required this.funkcija,
    this.horizontalMargin,
    required this.buttonText,
    required this.color,
    this.textColor = Colors.white,
    required this.isBorder,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => funkcija(),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: visina,
          horizontal: sirina == null ? 0 : sirina!,
        ),
        margin: EdgeInsets.symmetric(horizontal: horizontalMargin!),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: isBorder ? Theme.of(context).primaryColor : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Center(
          child: Text(
            buttonText,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: fontsize == null ? 20 : fontsize,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
