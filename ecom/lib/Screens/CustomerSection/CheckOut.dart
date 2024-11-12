import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Checkout extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const Checkout({Key? key, required this.cartItems}) : super(key: key);
//angel I just can't do it we are going to //finish the job
  @override
  State<Checkout> createState() => _CheckoutState();
}
//there is hope in Christ

class _CheckoutState extends State<Checkout> {
  late List<Map<String, dynamic>> _checkoutItems;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _checkoutItems = List.from(widget.cartItems);
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    print(userJson);
    if (userJson != null) {
      final userData = json.decode(userJson);
      setState(() {
        userEmail = userData['email'];
      });
    }
  }

  void _updateQuantity(int index, int change) {
    setState(() {
      _checkoutItems[index]['quantity'] += change;
      if (_checkoutItems[index]['quantity'] <= 0) {
        _checkoutItems.removeAt(index);
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      _checkoutItems.removeAt(index);
    });
  }

  double get totalPrice {
    return _checkoutItems.fold(
      0.0,
      (sum, item) =>
          sum + (item['Price'] as double) * (item['quantity'] as int),
    );
  }

  Future<void> _placeOrder() async {
    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final orderData = {
      'user': userEmail,
      'items': _checkoutItems
          .map((item) => {
                'item': item['_id'],
                'quantity': item['quantity'],
              })
          .toList(),
      'totalAmount': totalPrice,
      'shippingAddress': {
        'street': '123 whatever',
        'city': 'Ghost Town',
        'country': 'Ghana',
        'zipCode': '0454',
      },
    };

    try {
      final response = await http.post(
        Uri.parse('https://ecom-node-back.vercel.app/newOrder'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        Navigator.of(context).pushReplacementNamed('/History');
      } else {
        throw Exception('Failed to place order');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _checkoutItems.length,
              itemBuilder: (context, index) {
                final item = _checkoutItems[index];
                return Dismissible(
                  key: Key(item['_id'].toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) => _removeItem(index),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    title: Text(item['name']),
                    subtitle: Text(NumberFormat.currency(symbol: '\$')
                        .format(item['Price'])),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => _updateQuantity(index, -1),
                        ),
                        Text('${item['quantity']}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _updateQuantity(index, 1),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  NumberFormat.currency(symbol: '\$').format(totalPrice),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _placeOrder,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Place Order'),
            ),
          ),
        ],
      ),
    );
  }
}
