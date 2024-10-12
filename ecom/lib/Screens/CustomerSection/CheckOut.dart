import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class Checkout extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const Checkout({super.key, required this.cartItems});

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  late List<Map<String, dynamic>> _checkoutItems;

  @override
  void initState() {
    super.initState();
    _checkoutItems = List.from(widget.cartItems);
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
              onPressed: () async {
//  sending the infromation to the backend
                final responce =
                    await
                     http.get(Uri.parse('https://ecom-node-back.vercel.app/newOrder'));

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order placed successfully!')),
                );
              },
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
