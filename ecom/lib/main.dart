import 'package:ecom/Screens/CustomerSection/ProductListScreen.dart';
import 'package:flutter/material.dart';

import 'Screens/Admin/ItemBoardScreen.dart';
// import 'package:flutter_paystack/flutter_paystack.dart';

// final plugin = PaystackPlugin();

void main() {
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
    home: ProductListScreen(),
      debugShowCheckedModeBanner: false,

    routes: {
       "/AdminScreen" : (context)=>  ItemBoardScreen(),
       "/Home" : (context)=> const  ProductListScreen(),
       "Order":(context)=> ItemBoardScreen()
    },
    
    );
  }
}
