import 'package:ecom/Screens/Glosory/ProductListScreen.dart';
import 'package:ecom/Screens/Upload/UploadFile.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

//   the stating pint of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //   the building of the real deal
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Ecoms", home: ImageUploadScreen());
  }
}
