import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String buttonText;
  final Color? color, textColor;
  final bool isBorder;
  final double visina;
  final double? fontsize;
  final double? sirina;
  final double borderRadius;
  final Function funkcija;
  final bool isFullWidth;

  Button({
    required this.buttonText,
    required this.borderRadius,
    required this.visina,
    required this.color,
    required this.isBorder,
    required this.funkcija,
    this.fontsize,
    this.sirina,
    this.textColor = Colors.white,
    required this.isFullWidth,
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
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: isBorder ? Theme.of(context).primaryColor : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: isFullWidth
            ? Center(
                child: Text(
                  buttonText,
                  style: Theme.of(context).textTheme.headline3!.copyWith(
                        // fontWeight: FontWeight.w600,
                        fontSize: fontsize ?? 20,
                        color: textColor,
                      ),
                ),
              )
            : Text(
                buttonText,
                style: Theme.of(context).textTheme.headline3!.copyWith(
                      // fontWeight: FontWeight.w600,
                      fontSize: fontsize ?? 20,
                      color: textColor,
                    ),
              ),
      ),
    );
  }
}
