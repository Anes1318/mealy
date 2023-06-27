import 'package:flutter/material.dart';

import '../../components/CustomAppbar.dart';

class OmiljeniScreen extends StatefulWidget {
  static const String routeName = '/OmiljeniScreen';

  const OmiljeniScreen({super.key});

  @override
  State<OmiljeniScreen> createState() => _OmiljeniScreenState();
}

class _OmiljeniScreenState extends State<OmiljeniScreen> {
  @override
  List<TextEditingController> _textControllers = [];

  @override
  void dispose() {
    for (var controller in _textControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addTextField() {
    setState(() {
      _textControllers.add(TextEditingController());
    });
  }

  Widget build(BuildContext context) {
    final medijakveri = MediaQuery.of(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          CustomAppBar(pageTitle: 'Omiljeni', isCenter: false),
          SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _textControllers.length,
                  itemBuilder: (context, index) {
                    return TextField(
                      controller: _textControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Text Field ${index + 1}',
                      ),
                    );
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addTextField,
                  child: Text('Add Text Field'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
