import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:path/path.dart' as path;
import 'dart:io';
import '../../l10n/app_localizations.dart';
import '../../services/supabase_service.dart';

class Product {
  final int id;
  final String name;
  final String farmName;
  final String state;
  final String type;
  final int price;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.farmName,
    required this.state,
    required this.type,
    required this.price,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': name,
      'farm_name': farmName,
      'location': state,
      'type': type,
      'price': price,
      'image_url': imageUrl,
    };
  }
}

class ProductsScreen extends StatefulWidget {
  static const routeName = '/farmer-products';

  const ProductsScreen({Key? key}) : super(key: key);

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  final List<String> _productTypes = [
    'Poultry',
    'Vegetable',
    'Fruits',
    'Crops'
  ];
  final List<String> _states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal'
  ];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() => _isLoading = true);
      final products = await SupabaseService().getProducts();
      setState(() {
        _products = products
            .map((data) => Product(
                  id: data['id'] ?? 0,
                  name: data['product_name'] ?? '',
                  farmName: data['farm_name'] ?? '',
                  state: data['location'] ?? '',
                  type: data['type'] ?? '',
                  price: data['price'] ?? 0,
                  imageUrl: data['image_url'],
                ))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading products: ${e.toString()}')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProductToDatabase(Product product) async {
    try {
      // Create a map with only non-null values
      final Map<String, dynamic> productData = {
        'product_name': product.name,
        'farm_name': product.farmName,
        'location': product.state,
        'type': product.type,
        'price': product.price,
      };

      // Only add image_url if it's not null
      if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
        productData['image_url'] = product.imageUrl;
      }

      await SupabaseService().addProduct(productData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving product: ${e.toString()}')),
        );
      }
    }
  }

  Future<String?> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return null;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploading image...')),
      );

      final String imageUrl = await SupabaseService().uploadProductImage(
        File(image.path),
        '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully!')),
        );
      }
      return imageUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: ${e.toString()}')),
        );
      }
      return null;
    }
  }

  void _showAddProductSheet() {
    final appLocalizations = AppLocalizations.of(context);
    final _formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final farmNameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String? selectedType;
    String? selectedState;
    String? imageUrl;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(appLocalizations.addProductTitle,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: 'Product Name'),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Please enter product name'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: farmNameCtrl,
                  decoration: InputDecoration(labelText: 'Farm Name'),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Please enter farm name'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Location'),
                  value: selectedState,
                  items: _states
                      .map((state) => DropdownMenuItem(
                            value: state,
                            child: Text(state),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() {
                    selectedState = value;
                  }),
                  validator: (val) =>
                      val == null ? 'Please select state' : null,
                  menuMaxHeight: 300,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: appLocalizations.type),
                  value: selectedType,
                  items: _productTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() {
                    selectedType = value;
                  }),
                  validator: (val) =>
                      val == null ? appLocalizations.selectType : null,
                  menuMaxHeight: 200,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Price per kg (₹)'),
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || int.tryParse(val) == null
                      ? 'Please enter valid price'
                      : null,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final newImageUrl = await _pickAndUploadImage();
                      setState(() {
                        imageUrl = newImageUrl;
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Image uploaded successfully')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Error uploading image: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.add_photo_alternate),
                  label: Text(imageUrl == null
                      ? 'Add Product Image'
                      : 'Change Product Image'),
                ),
                if (imageUrl != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate() &&
                        selectedType != null &&
                        selectedState != null) {
                      final newProduct = Product(
                        id: 0,
                        name: nameCtrl.text,
                        farmName: farmNameCtrl.text,
                        state: selectedState!,
                        type: selectedType!,
                        price: int.parse(priceCtrl.text),
                        imageUrl: imageUrl,
                      );

                      await _saveProductToDatabase(newProduct);
                      setState(() {
                        _products.add(newProduct);
                      });
                      Navigator.of(ctx).pop();
                    }
                  },
                  child: Text(appLocalizations.add),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditProductSheet(int index) {
    final appLocalizations = AppLocalizations.of(context);
    final _formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: _products[index].name);
    final farmNameCtrl = TextEditingController(text: _products[index].farmName);
    final priceCtrl =
        TextEditingController(text: _products[index].price.toString());
    String? selectedType = _products[index].type;
    String? selectedState = _products[index].state;
    String? imageUrl = _products[index].imageUrl;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(appLocalizations.editProductTitle,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Please enter product name'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: farmNameCtrl,
                  decoration: const InputDecoration(labelText: 'Farm Name'),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Please enter farm name'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'State'),
                  value: selectedState,
                  items: _states
                      .map((state) => DropdownMenuItem(
                            value: state,
                            child: Text(state),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() {
                    selectedState = value;
                  }),
                  validator: (val) =>
                      val == null ? 'Please select state' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: appLocalizations.type),
                  value: selectedType,
                  items: _productTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() {
                    selectedType = value;
                  }),
                  validator: (val) =>
                      val == null ? appLocalizations.selectType : null,
                  menuMaxHeight: 300,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Price per kg (₹)'),
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || int.tryParse(val) == null
                      ? 'Please enter valid price'
                      : null,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final newImageUrl = await _pickAndUploadImage();
                      setState(() {
                        imageUrl = newImageUrl;
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Image uploaded successfully')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Error uploading image: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.add_photo_alternate),
                  label: Text(imageUrl == null
                      ? 'Add Product Image'
                      : 'Change Product Image'),
                ),
                if (imageUrl != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate() &&
                        selectedType != null &&
                        selectedState != null) {
                      final updatedProduct = Product(
                        id: _products[index].id,
                        name: nameCtrl.text,
                        farmName: farmNameCtrl.text,
                        state: selectedState!,
                        type: selectedType!,
                        price: int.parse(priceCtrl.text),
                        imageUrl: imageUrl,
                      );

                      await _saveProductToDatabase(updatedProduct);
                      setState(() {
                        _products[index] = updatedProduct;
                      });
                      Navigator.of(ctx).pop();
                    }
                  },
                  child: Text(appLocalizations.save),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(int index) {
    final product = _products[index];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Delete the image from storage if it exists
                if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
                  await SupabaseService().deleteProductImage(product.imageUrl!);
                }

                // Delete the product from database
                await SupabaseService().deleteProduct(product.id.toString());

                setState(() {
                  _products.removeAt(index);
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                Navigator.of(ctx).pop();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting product: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.products),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading
                ? null
                : () {
                    _loadProducts();
                  },
            tooltip: 'Refresh Products',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text(
                        appLocalizations.products,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E603A),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _showAddProductSheet,
                        icon: const Icon(Icons.add),
                        label: Text(appLocalizations.addProduct),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: appLocalizations.searchProducts,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return _buildProductCard(
                        name: product.name,
                        farmName: product.farmName,
                        state: product.state,
                        type: product.type,
                        price: product.price,
                        imageUrl: product.imageUrl,
                        onEdit: () {
                          _showEditProductSheet(index);
                        },
                        onDelete: () {
                          _confirmDelete(index);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProductCard({
    required String name,
    required String farmName,
    required String state,
    required String type,
    required int price,
    String? imageUrl,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    final appLocalizations = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Error loading image: $error');
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.broken_image,
                              size: 40, color: Colors.grey),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        const Icon(Icons.image, size: 40, color: Colors.grey),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        farmName,
                        style: const TextStyle(
                          color: Color(0xFF2E603A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state,
                        style: const TextStyle(
                          color: Color(0xFF2E603A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        type,
                        style: const TextStyle(
                          color: Color(0xFF2E603A),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: onEdit,
                  color: Colors.blue,
                  tooltip: appLocalizations.edit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                  color: Colors.red,
                  tooltip: appLocalizations.delete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '₹$price/kg',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
