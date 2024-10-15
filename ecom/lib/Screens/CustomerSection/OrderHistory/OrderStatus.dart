import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson == null) {
        throw Exception('User not logged in');
      }

      final userData = json.decode(userJson);
      final userEmail = userData['email'];

      final response = await http.get(
        Uri.parse('https://ecom-node-back.vercel.app/orders/$userEmail'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> ordersJson = json.decode(response.body);
        setState(() {
          _orders = ordersJson.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      setState(() {
        _orders = [];
        _isLoading = false;
      });
    }
  }

//  this function called the fetchOrders again
  void RefreshPage() {
    //   ti
    _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        actions: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.transparent),
            child: Row(children: [
              ElevatedButton(
                  onPressed: () {
                    RefreshPage();
                  },
                  child: Text(
                    "RefreshPage",
                    style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w100),
                  )),
              // FOR THE APYEMENT PLACE
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed("/Pay");
                  },
                  child: const Text("Payment"))
            ]),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('No orders found'))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ExpansionTile(
                        title: Text('Order #${order['_id'].substring(0, 8)}'),
                        subtitle: Text(
                          'Status: ${order['status']} - ${DateFormat('MMM d, yyyy').format(DateTime.parse(order['orderDate']))}',
                        ),
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: order['items'].length,
                            itemBuilder: (context, itemIndex) {
                              final item = order['items'][itemIndex];
                              return ListTile(
                                title: Text(item['item']['name']),
                                subtitle: Text('Quantity: ${item['quantity']}'),
                                trailing: Text(
                                  NumberFormat.currency(symbol: '\$').format(
                                    item['item']['Price'] * item['quantity'],
                                  ),
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  NumberFormat.currency(symbol: '\$').format(
                                    order['totalAmount'],
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
