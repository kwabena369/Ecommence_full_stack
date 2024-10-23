import 'package:ecom/Screens/CustomerSection/CheckOut.dart';
import 'package:ecom/Widget/SingleItem.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Map<String, dynamic>> cartItems = [];
  List<Map<String, dynamic>> _items = [];
  // this section is the defination of the filter
  List<Map<String, dynamic>> _filteredItems = [];

  bool _isLoading = true;
  Map<String, dynamic>? _userData;
//  this is a section for  search thing
  final TextEditingController _searchController = TextEditingController();
  String _selectedPriceRange = 'All';
  final List<String> _priceRanges = [
    'All',
    'Under \$50',
    '\$50-\$100',
    'Over \$100'
  ];

  @override
  void initState() {
    super.initState();
    _fetchItems();
    _loadUserData();
   _searchController.addListener(_onSearchChanged);

  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

   void _onSearchChanged() {
    _filterItems();
  }
  void _filterItems() {
    setState(() {
      _filteredItems = _items.where((item) {
        bool matchesSearch = item['name']
            .toString()
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());

        if (_selectedPriceRange == 'All') {
          return matchesSearch;
        }

        double price = (item['Price'] as num).toDouble();
        switch (_selectedPriceRange) {
          case 'Under \$50':
            return matchesSearch && price < 50;
          case '\$50-\$100':
            return matchesSearch && price >= 50 && price <= 100;
          case 'Over \$100':
            return matchesSearch && price > 100;
          default:
            return matchesSearch;
        }
      }).toList();
    });
  }
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString('user');
    if (userJson != null) {
      setState(() {
        _userData = json.decode(userJson);
      });
    }
  }

Future<void> _fetchItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('https://ecom-node-back.vercel.app/items'));
      if (response.statusCode == 200) {
        setState(() {
          _items = List<Map<String, dynamic>>.from(json.decode(response.body));
          _filteredItems = _items; // Initialize filtered items
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      print('Error fetching items: $e');
      setState(() {
        _items = [];
        _filteredItems = [];
        _isLoading = false;
      });
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    Navigator.pushReplacementNamed(context, '/AuthenScreen');
  }

  void addToCart(Map<String, dynamic> product) {
    setState(() {
      int index = cartItems.indexWhere((item) => item['_id'] == product['_id']);
      if (index != -1) {
        cartItems[index]['quantity']++;
      } else {
        cartItems.add({
          ...product,
          'quantity': 1,
          'Price': (product['Price'] as num).toDouble(),
        });
      }
    });
    _showAddToCartFeedback();
  }

  double get totalPrice {
    return cartItems.fold(
      0.0,
      (sum, item) =>
          sum + ((item['Price'] as num).toDouble() * (item['quantity'] as int)),
    );
  }

  void updateQuantity(String id, int change) {
    setState(() {
      int index = cartItems.indexWhere((item) => item['_id'] == id);
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
      cartItems.removeWhere((item) => item['_id'] == id);
    });
  }

  int get cartItemCount {
    return cartItems.fold(0, (sum, item) => sum + (item['quantity'] as int));
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

//   the ui for the search there
Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          // Price Range Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _priceRanges.map((range) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: _selectedPriceRange == range,
                    label: Text(range),
                    onSelected: (selected) {
                      setState(() {
                        _selectedPriceRange = selected ? range : 'All';
                        _filterItems();
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.orange.withOpacity(0.8),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
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
            key: Key(item['_id']),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              setModalState(() => removeItem(item['_id']));
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
                NumberFormat.currency(symbol: '\$')
                    .format((item['Price'] as num).toDouble()),
                style: TextStyle(color: Colors.green[700]),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline,
                        color: Colors.red[400]),
                    onPressed: () =>
                        setModalState(() => updateQuantity(item['_id'], -1)),
                  ),
                  Text('${item['quantity']}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline,
                        color: Colors.green[400]),
                    onPressed: () =>
                        setModalState(() => updateQuantity(item['_id'], 1)),
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
            foregroundColor: Colors.white,
            backgroundColor: Colors.green[600],
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () {
            Navigator.pop(context); // Close the cart overlay
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Checkout(cartItems: cartItems),
              ),
            );
          },
          child: const Text('Proceed to Checkout'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '💀',
          style: TextStyle(
              color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent.withOpacity(0.4),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: _showCartOverlay,
                color: Colors.white,
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue,
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💀_Original Gangster',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  SizedBox(height: 10),
                  if (_userData != null) ...[
                    Text(
                      'Welcome, ${_userData!['email']}',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Orders'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/Order");
              },
            ),
            ListTile(
              leading: const Icon(Icons.history_rounded),
              title: const Text('History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/History");
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Admin'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/AdminScreen");
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/AdminScreen");
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchAndFilter(),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final product = _filteredItems[index];
                      return SingleItem(
                        previewItem: product['name'] ?? '',
                        priceItem:
                            (product['Price'] as num?)?.toDouble() ?? 0.0,
                        itemId: product['_id']?.toString() ?? '',
                        ratingItem: 5,
                        base64Image:
                            product['PreviewItem_Base_Content'] as String?,
                        onAddToCart: () => addToCart(product),
                        onFavoriteToggle: () {},
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
