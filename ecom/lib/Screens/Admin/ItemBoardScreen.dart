import 'dart:convert';
import 'dart:typed_data';
import 'package:ecom/Widget/AdminSingleItems.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ItemBoardScreen extends StatefulWidget {
  @override
  _ItemBoardScreenState createState() => _ItemBoardScreenState();
}

class _ItemBoardScreenState extends State<ItemBoardScreen> {
  final _formKey = GlobalKey<FormState>();
  String _itemName = '';
  double _itemPrice = 0.0;
  String _itemAim = '';
  Uint8List? _imageBytes;
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchItems();
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
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      print('Error fetching items: $e');
      setState(() {
        _items = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _uploadItem() async {
    if (_formKey.currentState!.validate() && _imageBytes != null) {
      _formKey.currentState!.save();

      String base64Image = base64Encode(_imageBytes!);

      final response = await http.post(
        Uri.parse('https://ecom-node-back.vercel.app/UploadFile'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'name': _itemName,
          'price': _itemPrice,
          'aim': _itemAim,
          'previewItemBaseContent': base64Image,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item uploaded successfully')),
        );
        Navigator.pop(context);
        _fetchItems();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload item')),
        );
      }
    }
  }

  Future<void> _deleteItem(String itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('https://ecom-node-back.vercel.app/items/$itemId'),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item deleted successfully')),
        );
        _fetchItems();
      } else {
        throw Exception('Failed to delete item');
      }
    } catch (e) {
      print('Error deleting item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete item')),
      );
    }
  }

  Future<void> _updateItem(String itemId) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String base64Image =
          _imageBytes != null ? base64Encode(_imageBytes!) : '';

      try {
        final response = await http.put(
          Uri.parse('https://ecom-node-back.vercel.app/items/$itemId'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'name': _itemName,
            'price': _itemPrice,
            'aim': _itemAim,
            'previewItemBaseContent': base64Image,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Item updated successfully')),
          );
          Navigator.pop(context);
          _fetchItems();
        } else {
          throw Exception('Failed to update item');
        }
      } catch (e) {
        print('Error updating item: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update item')),
        );
      }
    }
  }

  void _showAddItemModal() {
    _itemName = '';
    _itemPrice = 0.0;
    _itemAim = '';
    _imageBytes = null;
    _showItemModal(isEdit: false);
  }

  void _showEditItemModal(Map<String, dynamic> item) {
    _itemName = item['name'] ?? '';
    _itemPrice = (item['price'] as num?)?.toDouble() ?? 0.0;
    _itemAim = item['aim'] ?? '';
    _imageBytes = item['PreviewItem_Base_Content'] != null
        ? base64Decode(item['PreviewItem_Base_Content'])
        : null;
    _showItemModal(isEdit: true, itemId: item['id']);
  }

  void _showItemModal({required bool isEdit, String? itemId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: _itemName,
                    decoration: InputDecoration(labelText: 'Item Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an item name';
                      }
                      return null;
                    },
                    onSaved: (value) => _itemName = value ?? '',
                  ),
                  TextFormField(
                    initialValue: _itemPrice.toString(),
                    decoration: InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                    onSaved: (value) => _itemPrice = double.parse(value ?? '0'),
                  ),
                  TextFormField(
                    initialValue: _itemAim,
                    decoration: InputDecoration(labelText: 'Aim'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an aim';
                      }
                      return null;
                    },
                    onSaved: (value) => _itemAim = value ?? '',
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text(isEdit ? 'Change Image' : 'Select Image'),
                  ),
                  if (_imageBytes != null)
                    Image.memory(_imageBytes!, height: 100),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        isEdit ? () => _updateItem(itemId!) : _uploadItem,
                    child: Text(isEdit ? 'Update Item' : 'Submit'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: _showAddItemModal,
            icon: Icon(Icons.add, color: Colors.white),
            label: const Text(
              "Add Item",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory, size: 100, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No items yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child: GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final product = _items[index];
                      return AdminSingleItem(
                        previewItem: product['name'] ?? '',
                        priceItem:
                            (product['price'] as num?)?.toDouble() ?? 0.0,
                        itemId: product['id']?.toString() ?? '',
                        ratingItem:
                            5, // You may want to implement a real rating system
                        base64Image:
                            product['PreviewItem_Base_Content'] as String?,
                        onDelete: () => _deleteItem(product['id']),
                        onEdit: () => _showEditItemModal(product),
                      );
                    },
                  ),
                ),
    );
  }


}

            // onAddToCart: () => addToCart(product),
