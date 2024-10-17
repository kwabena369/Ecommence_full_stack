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

  void _refreshPage() {
    _fetchOrders();
  }

  void _navigateToPayment(double amount) {
    Navigator.of(context).pushNamed('/Pay', arguments: amount);
  }

  Widget _buildStatusIcon(String status) {
    IconData iconData;
    Color color;
    switch (status.toLowerCase()) {
      case 'processing':
        iconData = Icons.hourglass_empty;
        color = Colors.orange;
        break;
      case 'shipped':
        iconData = Icons.local_shipping;
        color = Colors.blue;
        break;
      case 'delivered':
        iconData = Icons.check_circle;
        color = Colors.green;
        break;
      default:
        iconData = Icons.info;
        color = Colors.grey;
    }
    return Icon(iconData, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPage,
          ),
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
                        leading: _buildStatusIcon(order['status']),
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
                          if (order['status'].toLowerCase() != 'pending')
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: ElevatedButton(
                                child: const Text('Pay Now'),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white, backgroundColor: Colors.green,
                                ),
                                onPressed: () => _navigateToPayment(
                                    order['totalAmount'].toDouble()),
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
