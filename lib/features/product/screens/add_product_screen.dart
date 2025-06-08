import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventrack_frontend/data/data_providers/product_api.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController skuController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Uint8List? _webImage;
  XFile? _mobileImage;

  bool isLoading = false;
  String? errorMessage;

  // Add category selection
  String _selectedCategory = 'other';

  // Category choices matching your Django model
  static const List<Map<String, String>> categoryChoices = [
    {'value': 'other', 'label': 'Other'},
    {'value': 'electronics', 'label': 'Electronics'},
    {'value': 'clothing', 'label': 'Clothing'},
    {'value': 'home', 'label': 'Home'},
    {'value': 'toys', 'label': 'Toys'},
    {'value': 'books', 'label': 'Books'},
    {'value': 'sports', 'label': 'Sports'},
    {'value': 'automotive', 'label': 'Automotive'},
    {'value': 'health', 'label': 'Health'},
    {'value': 'beauty', 'label': 'Beauty'},
    {'value': 'garden', 'label': 'Garden'},
    {'value': 'computers', 'label': 'Computers'},
    {'value': 'jewelry', 'label': 'Jewelry'},
    {'value': 'musical_instruments', 'label': 'Musical Instruments'},
    {'value': 'office_products', 'label': 'Office Products'},
    {'value': 'pet_supplies', 'label': 'Pet Supplies'},
    {'value': 'tools', 'label': 'Tools'},
    {'value': 'video_games', 'label': 'Video Games'},
    {'value': 'baby', 'label': 'Baby'},
    {'value': 'groceries', 'label': 'Groceries'},
    {'value': 'furniture', 'label': 'Furniture'},
    {'value': 'appliances', 'label': 'Appliances'},
    {'value': 'clothing_shoes', 'label': 'Clothing & Shoes'},
    {'value': 'bags', 'label': 'Bags'},
    {'value': 'accessories', 'label': 'Accessories'},
    {'value': 'watches', 'label': 'Watches'},
    {'value': 'phones', 'label': 'Phones'},
    {'value': 'tablets', 'label': 'Tablets'},
    {'value': 'cameras', 'label': 'Cameras'},
    {'value': 'drones', 'label': 'Drones'},
    // Add more as needed
  ];

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _webImage = result.files.single.bytes!;
        });
      }
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _mobileImage = pickedFile;
        });
      }
    }
  }

  Widget _buildImagePreview() {
    if (_webImage == null && _mobileImage == null) {
      return Container(
        width: 100,
        height: 100,
        color: Colors.grey[300],
        child: const Icon(Icons.camera_alt, size: 40),
      );
    }

    if (kIsWeb && _webImage != null) {
      return Image.memory(
        _webImage!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    } else if (_mobileImage != null) {
      return Image.file(
        File(_mobileImage!.path),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }

    return const SizedBox();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final name = nameController.text.trim();
    final sku = skuController.text.trim();
    final price = double.tryParse(priceController.text) ?? 0;
    final quantity = int.tryParse(quantityController.text) ?? 0;
    final description = descriptionController.text.trim();

    Map<String, dynamic> result;

    if (kIsWeb && _webImage != null) {
      result = await ProductApiService.createProduct(
        name: name,
        sku: sku,
        price: price,
        quantity: quantity,
        description: description,
        category: _selectedCategory,
        imageBase64: base64Encode(_webImage!),
      );
    } else if (_mobileImage != null) {
      result = await ProductApiService.createProduct(
        name: name,
        sku: sku,
        price: price,
        quantity: quantity,
        description: description,
        category: _selectedCategory,
        imageFile: File(_mobileImage!.path),
      );
    } else {
      result = await ProductApiService.createProduct(
        name: name,
        sku: sku,
        price: price,
        quantity: quantity,
        description: description,
        category: _selectedCategory,
      );
    }

    setState(() {
      isLoading = false;
    });

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!')),
      );
      Navigator.pop(context);
    } else {
      setState(() {
        errorMessage = result['error'] ?? 'Failed to add product';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            elevation: 8,
            margin: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Add New Product",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: _pickImage,
                        child: _buildImagePreview(),
                      ),
                      const SizedBox(height: 16),
                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
                        ),
                        items: categoryChoices
                            .map((cat) => DropdownMenuItem<String>(
                                  value: cat['value'],
                                  child: Text(cat['label']!),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedCategory = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Product Name',
                          prefixIcon: Icon(Icons.inventory_2),
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Enter product name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: skuController,
                        decoration: const InputDecoration(
                          labelText: 'SKU',
                          prefixIcon: Icon(Icons.qr_code),
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Enter SKU' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          prefixIcon: Icon(Icons.attach_money),
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Enter price';
                          final price = double.tryParse(val);
                          if (price == null || price < 0) {
                            return 'Enter valid price';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          prefixIcon: Icon(Icons.numbers),
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty)
                            return 'Enter quantity';
                          final qty = int.tryParse(val);
                          if (qty == null || qty < 0) {
                            return 'Enter valid quantity';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text('Add Product'),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors.blue[700],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _submit,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
