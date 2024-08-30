import 'package:flutter/material.dart';
import 'package:shorts/constants.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Center(
        child: TextButton(onPressed: (){
          authController.signOut();
        }, child: const Text("Sign out")),
      ),
    );
  }
}
