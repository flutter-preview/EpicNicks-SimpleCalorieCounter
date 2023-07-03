

import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() =>
    _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(flex: 5),
              Text("Settings"),
              Spacer(flex: 1),
              Icon(Icons.settings),
              Spacer(flex: 5)
            ],
          ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
        TextButton(
            onPressed: (){},
            child: const Text("User Data")
        )
      ],
      )
    );
  }

}