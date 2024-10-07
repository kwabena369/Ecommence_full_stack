import 'package:ecommenceapp/Screens/CheckOut/PayPalCheckoutScreen.dart';
import 'package:flutter/material.dart';
import 'package:ecommenceapp/Widget/SingleItem.dart';
import 'package:intl/intl.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

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
        content: const Text('Item added to cart'),
        duration: const Duration(seconds: 2),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildCartItemsList(setModalState),
                  const SizedBox(height: 24),
                  _buildTotalPrice(),
                  const SizedBox(height: 24),
                  _buildCheckoutButtons(context),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2.5),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Your Shopping Cart',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCartItemsList(StateSetter setModalState) {
    return Expanded(
      child: ListView.separated(
        itemCount: cartItems.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = cartItems[index];
          return Dismissible(
            key: Key(item['id']),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              setModalState(() => removeItem(item['id']));
            },
            background: Container(
              color: Colors.red[400],
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              leading: CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: Text(item['name'][0],
                    style: const TextStyle(color: Colors.black87)),
              ),
              title: Text(
                item['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                NumberFormat.currency(symbol: '\$').format(item['price']),
                style: TextStyle(color: Colors.green[700]),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline,
                        color: Colors.red[400]),
                    onPressed: () =>
                        setModalState(() => updateQuantity(item['id'], -1)),
                  ),
                  Text('${item['quantity']}',
                      style:
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline,
                        color: Colors.green[400]),
                    onPressed: () =>
                        setModalState(() => updateQuantity(item['id'], 1)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotalPrice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(
            NumberFormat.currency(symbol: '\$').format(totalPrice),
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.green[600],
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () => Navigator.pop(context),
          child: Text('Proceed to Checkout'),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: Icon(Icons.paypal, color: Colors.blue[900]),
          label: const Text('Checkout with PayPal'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.blue[900], backgroundColor: Colors.blue[50],
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () {
            Navigator.pop(context);
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => 
          //     ),
          //   );
          //   the same ssection for the other
          },
        ),
      ],
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
        title: const Text('Products'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: _showCartOverlay,
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$cartItemCount',
                      style: const TextStyle(
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
        padding: const EdgeInsets.all(16),
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
