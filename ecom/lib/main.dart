import 'package:ecom/Screens/Authentication/Authenticate.dart';
import 'package:ecom/Screens/CustomerSection/OrderHistory/OrderStatus.dart';
import 'package:ecom/Screens/CustomerSection/ProductListScreen.dart';
import 'package:ecom/Screens/TestingPayment/Payment.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'Screens/Admin/ItemBoardScreen.dart';
// import 'package:flutter_paystack/flutter_paystack.dart';

// final plugin = PaystackPlugin();

void main()async {


  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
    WidgetsFlutterBinding.ensureInitialized();
  // plugin.initialize(publicKey: 'pk_test_f7353ba84f6321eb54daa5701fcc043e1c0f32c9');
}

//   the stating pint of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //   the building of the real deal
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Ecoms", 
    home: const AuthScreen(),
      debugShowCheckedModeBanner: false,

    routes: {
       "/AdminScreen" : (context)=>  const ItemBoardScreen(),
       "/Home" : (context)=> const  ProductListScreen(),
       "/Order":(context)=> const ItemBoardScreen(),
       "/AuthenScreen":(context) =>const AuthScreen(),
       "/History":(context)=>const OrdersScreen(),
       "/Pay":(context)=> PaymentScreen()
    },
    );
  }
}
