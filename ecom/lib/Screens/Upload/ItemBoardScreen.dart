import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ItemBoardScreen extends StatefulWidget {
  @override
  _ItemBoardScreenState createState() => _ItemBoardScreenState();
}

class _ItemBoardScreenState extends State<ItemBoardScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _itemName;
  double? _itemPrice;
  String? _itemAim;
  Uint8List? _imageBytes;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    final response =
        await http.get(Uri.parse('https://ecom-node-back.vercel.app/items'));
    if (response.statusCode == 200) {
      setState(() {
        _items = List<Map<String, dynamic>>.from(json.decode(response.body));
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

  void _showAddItemModal() {
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
                    decoration: InputDecoration(labelText: 'Item Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an item name';
                      }
                      return null;
                    },
                    onSaved: (value) => _itemName = value,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Price'),
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
                    onSaved: (value) => _itemPrice = double.parse(value!),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Aim'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an aim';
                      }
                      return null;
                    },
                    onSaved: (value) => _itemAim = value,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Select Image'),
                  ),
                  if (_imageBytes != null)
                    Image.memory(_imageBytes!, height: 100),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _uploadItem,
                    child: Text('Submit'),
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
        title: Text('ItemBoard'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddItemModal,
          ),
        ],
      ),
      body: _items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No items yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  leading: Image.memory(
                    base64Decode(item['PreviewItem_Base_Content']),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(item['name']),
                  subtitle:
                      Text('Price: \$${item['Price']} - Aim: ${item['Aim']}'),
                );
              },
            ),
    );
  }
}
