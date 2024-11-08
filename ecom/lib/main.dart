import 'package:ecom/Screens/SplashScreen/PhrontlyneSplashScreen/CompanySplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ecom/Screens/Authentication/Authenticate.dart';
import 'package:ecom/Screens/CustomerSection/OrderHistory/OrderStatus.dart';
import 'package:ecom/Screens/CustomerSection/ProductListScreen.dart';
import 'package:ecom/Screens/SplashScreen/SplashScreen.dart';
import 'package:ecom/Screens/TestingPayment/Payment.dart';
import 'package:ecom/Screens/Admin/ItemBoardScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Ecoms",
      home: CompanySplashScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        "/AdminScreen": (context) => const ItemBoardScreen(),
        "/Home": (context) => const ProductListScreen(),
        "/Order": (context) => const ItemBoardScreen(),
        "/AuthenScreen": (context) => const AuthScreen(),
        "/History": (context) => const OrdersScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/Pay') {
          final args = settings.arguments as double?;
          return MaterialPageRoute(
            builder: (context) => PaymentScreen(amount: args ?? 0.0),
          );
        }
        return null;
      },
    );
  }
}
// there is in the heart of man