import 'package:flutter/material.dart';
import 'package:flutter_controller/components/joystick.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  void handleChange(Offset value) {
    print(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Pad Example'),
      ),
      body: Column(
        children: [
          Center(
            child: Joystick(onChange: handleChange),
          ),
          Center(
            child: Joystick(onChange: handleChange),
          ),
        ],
      ),
    );
  }
}
