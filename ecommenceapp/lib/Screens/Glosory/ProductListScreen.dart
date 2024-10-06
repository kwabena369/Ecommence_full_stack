import 'package:flutter/material.dart';
import 'package:ecommenceapp/Widget/SingleItem.dart';
import 'package:intl/intl.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Map<String, dynamic>> cartItems = [];

  void addToCart(Map<String, dynamic> product) {
    setState(() {
      int index = cartItems.indexWhere((item) => item['id'] == product['id']);
      if (index != -1) {
        cartItems[index]['quantity']++;
      } else {
        cartItems.add({...product, 'quantity': 1});
      }
    });
    _showAddToCartFeedback();
  }

  void updateQuantity(String id, int change) {
    setState(() {
      int index = cartItems.indexWhere((item) => item['id'] == id);
      if (index != -1) {
        cartItems[index]['quantity'] += change;
        if (cartItems[index]['quantity'] <= 0) {
          cartItems.removeAt(index);
        }
      }
    });
  }

  void removeItem(String id) {
    setState(() {
      cartItems.removeWhere((item) => item['id'] == id);
    });
  }

  int get cartItemCount {
    return cartItems.fold(0, (sum, item) => sum + (item['quantity'] as int));
  }

  double get totalPrice {
    return cartItems.fold(
        0.0,
        (sum, item) =>
            sum + (item['price'] as double) * (item['quantity'] as int));
  }

  void _showAddToCartFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item added to cart'),
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: _showCartOverlay,
        ),
      ),
    );
  }

  void _showCartOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                children: [
                  Text(
                    'Your Cart',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return Dismissible(
                          key: Key(item['id']),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            setModalState(() {
                              removeItem(item['id']);
                            });
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          child: Card(
                            elevation: 2,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              title: Text(
                                item['name'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Price: ${NumberFormat.currency(symbol: '\$').format(item['price'])}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      setModalState(() {
                                        updateQuantity(item['id'], -1);
                                      });
                                    },
                                  ),
                                  Text(
                                    '${item['quantity']}',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      setModalState(() {
                                        updateQuantity(item['id'], 1);
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setModalState(() {
                                        removeItem(item['id']);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          NumberFormat.currency(symbol: '\$')
                              .format(totalPrice),
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700]),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    child: Text('Checkout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      textStyle:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      // Implement checkout functionality
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> products = [
      {'id': '1', 'name': 'Product 1', 'price': 19.99, 'rating': 4.5},
      {'id': '2', 'name': 'Product 2', 'price': 29.99, 'rating': 4.2},
      {'id': '3', 'name': 'Product 3', 'price': 39.99, 'rating': 4.8},
      // Add more products as needed
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: _showCartOverlay,
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$cartItemCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return SingleItem(
            previewItem: product['name'],
            priceItem: product['price'],
            itemId: product['id'],
            ratingItem: product['rating'],
            onAddToCart: () => addToCart(product),
            onFavoriteToggle: () {
              // Toggle favorite status
            },
          );
        },
      ),
    );
  }
}
