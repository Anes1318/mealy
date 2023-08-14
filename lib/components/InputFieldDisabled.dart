import 'package:flutter/material.dart';

class InputFieldDisabled extends StatelessWidget {
  final MediaQueryData medijakveri;
  final String label;
  final String text;
  const InputFieldDisabled({
    super.key,
    required this.medijakveri,
    required this.label,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.only(bottom: (medijakveri.size.height - medijakveri.padding.top) * 0.01),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                margin: EdgeInsets.only(left: medijakveri.size.width * 0.01, bottom: medijakveri.size.height * 0.01),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(bottom: medijakveri.size.height * 0.019),
            height: medijakveri.size.height * 0.066,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: medijakveri.size.width * 0.04),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
