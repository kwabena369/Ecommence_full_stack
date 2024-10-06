import 'package:flutter/material.dart';
import 'package:flutter_paypal_checkout/flutter_paypal_checkout.dart';

class PayPalCheckoutScreen extends StatelessWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> cartItems;

  PayPalCheckoutScreen({required this.totalAmount, required this.cartItems});

  @override
  Widget build(BuildContext context) {
    print("Building PayPalCheckoutScreen");
    // Start the PayPal checkout process immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("Calling _processPayment");
      _processPayment(context);
    });

    // Show a loading indicator while the PayPal screen is being prepared
    return Scaffold(
      appBar: AppBar(
        title: Text('PayPal Checkout'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Initializing PayPal Checkout...'),
          ],
        ),
      ),
    );
  }

  void _processPayment(BuildContext context) async {
    print("Processing payment");
    try {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => PaypalCheckout(
            sandboxMode: true,
            clientId:
                "AQB8Q2YPBuTyLoVHU84eB8KsM1erW9YEjWzHva7n2JMnjBGjh2tb2FcaBhZUUptpF6wB6obGtPa-nv9_",
            secretKey:
                "EKVXaafnlTalnxoRjA7OS2yZk_HHjbrZNoyK_wLdC2JRlj61VlAxb9UXwv3TCHh2-Hn2pwogk_bwO1-3",
            returnURL: "https://developer.paypal.com/dashboard/accounts/edit/5339179674269752920?accountName=sb-dvxio33189715@personal.example.com",
            cancelURL: "https://developer.paypal.com/dashboard/accounts/edit/5339179674269752920?accountName=sb-dvxio33189715@personal.example.com",
            transactions: [
              {
                "amount": {
                  "total": totalAmount.toStringAsFixed(2),
                  "currency": "USD",
                  "details": {
                    "subtotal": totalAmount.toStringAsFixed(2),
                    "shipping": '0',
                    "shipping_discount": 0
                  }
                },
                "description": "Your purchase from Our Store",
                "item_list": {
                  "items": cartItems
                      .map((item) => {
                            "name": item['name'],
                            "quantity": item['quantity'],
                            "price": item['price'].toStringAsFixed(2),
                            "currency": "USD"
                          })
                      .toList(),
                }
              }
            ],
            note: "Contact us for any questions on your order.",
            onSuccess: (Map params) async {
              print("onSuccess: $params");
              // Handle successful payment here
              Navigator.of(context).popUntil((route) => route.isFirst);
              // You might want to clear the cart and show a success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Payment Successful!')),
              );
            },
            onError: (error) {
              print("onError: $error");
              // Handle errors here
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Payment Error: $error')),
              );
            },
            onCancel: (params) {
              print('cancelled: $params');
              // Handle cancellation here
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Payment Cancelled')),
              );
            },
          ),
        ),
      );
      print("PaypalCheckout result: $result");
    } catch (e) {
      print("Error in _processPayment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }
}
