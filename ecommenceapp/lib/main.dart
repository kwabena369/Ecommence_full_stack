import 'package:ecommenceapp/Screens/Glosory/landing.dart';
import 'package:ecommenceapp/Screens/SignUp.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

//   the stating pint of the application
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  //   the building of the real deal
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Ecoms",
      home: Landing()
    );
  }
}
