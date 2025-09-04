import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../l10n/app_localizations.dart';
import '../../models/product.dart' as model;
import '../../providers/products_provider.dart';

class ProductsScreen extends StatefulWidget {
  static const routeName = '/farmer-products';

  const ProductsScreen({Key? key}) : super(key: key);

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<model.Product> _farmerProducts = [];
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final productsProvider =
          Provider.of<ProductsProvider>(context, listen: false);
      await productsProvider.fetchProducts();

      const currentFarmerId = 1;

      if (mounted) {
        setState(() {
          _farmerProducts = productsProvider.items
              .where((p) => p.farmerId == currentFarmerId)
              .toList();
          _isLoading = false;
        });

        print('Total products fetched: ${productsProvider.items.length}');
        print(
            'Products for farmer $currentFarmerId: ${_farmerProducts.length}');
        print(
            'Farmer products: ${_farmerProducts.map((p) => '${p.name} (ID: ${p.farmerId})').toList()}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading products: ${e.toString()}')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAddProductSheet() {
    final appLocalizations = AppLocalizations.of(context);
    final _formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final farmNameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();
    final weightCtrl = TextEditingController();
    String? selectedType;
    String? selectedState;
    String? selectedUnit;
    bool isOrganic = false;
    File? _imageFile;
    bool _isStep2 = false;
    bool _isAddingProduct = false;
    bool _isNextLoading = false; // Added for next button loading state

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: !_isAddingProduct,
      enableDrag: !_isAddingProduct,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          // Functions that use setModalState
          void _showStep2() async {
            if (_formKey.currentState!.validate() &&
                selectedType != null &&
                selectedState != null &&
                selectedUnit != null) {
              setModalState(() {
                _isNextLoading = true;
              });

              // Simulate processing time or actual validation
              await Future.delayed(Duration(milliseconds: 500));

              setModalState(() {
                _isStep2 = true;
                _isNextLoading = false;
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill all required fields'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }

          void _goBackToStep1() {
            setModalState(() {
              _isStep2 = false;
            });
          }

          void _closeBottomSheet() {
            if (!_isAddingProduct) {
              Navigator.of(ctx).pop();
            }
          }

          return WillPopScope(
            onWillPop: () async => !_isAddingProduct,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: AbsorbPointer(
                    absorbing: _isAddingProduct,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header with step indicator
                        Row(
                          children: [
                            IconButton(
                              onPressed: _isAddingProduct
                                  ? null
                                  : (_isStep2
                                      ? _goBackToStep1
                                      : _closeBottomSheet),
                              icon: Icon(
                                  _isStep2 ? Icons.arrow_back : Icons.close),
                            ),
                            Expanded(
                              child: Text(
                                _isStep2
                                    ? 'Add Product Image'
                                    : appLocalizations.addProductTitle,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Step indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: _isStep2
                                    ? Colors.grey
                                    : Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '1',
                                  style: TextStyle(
                                    color: _isStep2
                                        ? Colors.grey[600]
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 40,
                              height: 2,
                              color: _isStep2
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                            ),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: _isStep2
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '2',
                                  style: TextStyle(
                                    color: _isStep2
                                        ? Colors.white
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Step 1: Product Details Form
                        if (!_isStep2) ...[
                          TextFormField(
                            controller: nameCtrl,
                            decoration:
                                InputDecoration(labelText: 'Product Name'),
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
                            decoration:
                                const InputDecoration(labelText: 'Location'),
                            value: selectedState,
                            items: _states
                                .map((state) => DropdownMenuItem(
                                      value: state,
                                      child: Text(state),
                                    ))
                                .toList(),
                            onChanged: (value) => setModalState(() {
                              selectedState = value;
                            }),
                            validator: (val) =>
                                val == null ? 'Please select state' : null,
                            menuMaxHeight: 300,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: appLocalizations.type,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                            ),
                            value: selectedType,
                            items: _productTypes
                                .map((type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    ))
                                .toList(),
                            onChanged: (value) => setModalState(() {
                              selectedType = value;
                            }),
                            validator: (val) => val == null
                                ? appLocalizations.selectType
                                : null,
                            menuMaxHeight: 200,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: priceCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Price per kg (₹)'),
                            keyboardType: TextInputType.number,
                            validator: (val) =>
                                val == null || double.tryParse(val) == null
                                    ? 'Please enter valid price'
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: descriptionCtrl,
                            decoration:
                                InputDecoration(labelText: 'Description'),
                            validator: (val) => val == null || val.isEmpty
                                ? 'Please enter description'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: weightCtrl,
                            decoration: InputDecoration(labelText: 'Weight'),
                            keyboardType: TextInputType.number,
                            validator: (val) =>
                                val == null || double.tryParse(val) == null
                                    ? 'Please enter valid weight'
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            decoration:
                                const InputDecoration(labelText: 'Unit'),
                            value: selectedUnit,
                            items: ['kg', 'g', 'piece', 'dozen']
                                .map((unit) => DropdownMenuItem(
                                      value: unit,
                                      child: Text(unit),
                                    ))
                                .toList(),
                            onChanged: (value) => setModalState(() {
                              selectedUnit = value;
                            }),
                            validator: (val) =>
                                val == null ? 'Please select unit' : null,
                          ),
                          const SizedBox(height: 12),
                          CheckboxListTile(
                            value: isOrganic,
                            onChanged: (val) => setModalState(() {
                              isOrganic = val ?? false;
                            }),
                            title: const Text('Organic'),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isNextLoading ? null : _showStep2,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: _isNextLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Next',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                        ],

                        // Step 2: Image Selection and Add Product
                        if (_isStep2) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Text(
                                  'Add a product image to help customers identify your product',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: _isAddingProduct
                                      ? null
                                      : () async {
                                          try {
                                            final XFile? pickedImage =
                                                await _picker.pickImage(
                                                    source:
                                                        ImageSource.gallery);
                                            if (pickedImage != null) {
                                              setModalState(() {
                                                _imageFile =
                                                    File(pickedImage.path);
                                              });
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Error picking image: ${e.toString()}'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                  icon: const Icon(Icons.add_photo_alternate),
                                  label: Text(_imageFile == null
                                      ? 'Add Product Image'
                                      : 'Change Product Image'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[200],
                                    foregroundColor: Colors.black87,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 24),
                                  ),
                                ),
                                if (_imageFile != null) ...[
                                  const SizedBox(height: 16),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      _imageFile!,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isAddingProduct
                                  ? null
                                  : () async {
                                      if (_imageFile == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Please select an image.'),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                        return;
                                      }

                                      setModalState(() {
                                        _isAddingProduct = true;
                                      });

                                      try {
                                        final newProduct = model.Product(
                                          id: '',
                                          name: nameCtrl.text,
                                          description: descriptionCtrl.text,
                                          price: double.parse(priceCtrl.text),
                                          imageUrl: '',
                                          category: selectedType!,
                                          farmerId: 1,
                                          farmName: farmNameCtrl.text,
                                          weight: double.parse(weightCtrl.text),
                                          unit: selectedUnit!,
                                          isOrganic: isOrganic,
                                          location: selectedState!,
                                        );

                                        final result =
                                            await Provider.of<ProductsProvider>(
                                                    context,
                                                    listen: false)
                                                .addProduct(
                                                    newProduct, _imageFile!);

                                        if (!mounted) return;

                                        if (result['success']) {
                                          // Product added successfully
                                          Navigator.of(ctx).pop();
                                          await _loadProducts();
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(result[
                                                        'message'] ??
                                                    'Product added successfully!'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        } else {
                                          // AI validation failed
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  result['message'] ??
                                                      'Please add the correct image for this product',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                backgroundColor: Colors.orange,
                                                duration: Duration(seconds: 5),
                                                action: SnackBarAction(
                                                  label: 'OK',
                                                  textColor: Colors.white,
                                                  onPressed: () {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .hideCurrentSnackBar();
                                                  },
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      } catch (e) {
                                        print('Error adding product: $e');
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to add product: ${e.toString()}',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      } finally {
                                        if (mounted) {
                                          setState(() {
                                            _isAddingProduct = false;
                                          });
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: _isAddingProduct
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      appLocalizations.add,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditProductSheet(int index) {
    final productToEdit = _farmerProducts[index];
    final appLocalizations = AppLocalizations.of(context);
    final _formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: productToEdit.name);
    final farmNameCtrl = TextEditingController(text: productToEdit.farmName);
    final priceCtrl =
        TextEditingController(text: productToEdit.price.toString());
    String? selectedType = productToEdit.category;
    String? selectedState = productToEdit.location;

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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close),
                      ),
                      Expanded(
                        child: Text(
                          appLocalizations.editProductTitle,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Product Name'),
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
                    decoration:
                        InputDecoration(labelText: appLocalizations.type),
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
                    validator: (val) =>
                        val == null || double.tryParse(val) == null
                            ? 'Please enter valid price'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() &&
                          selectedType != null &&
                          selectedState != null) {
                        final updatedProduct = model.Product(
                          id: productToEdit.id,
                          name: nameCtrl.text,
                          farmName: farmNameCtrl.text,
                          location: selectedState!,
                          category: selectedType!,
                          price: double.parse(priceCtrl.text),
                          imageUrl: productToEdit.imageUrl,
                          description: productToEdit.description,
                          farmerId: productToEdit.farmerId,
                          isOrganic: productToEdit.isOrganic,
                          unit: productToEdit.unit,
                          weight: productToEdit.weight,
                        );

                        try {
                          await Provider.of<ProductsProvider>(context,
                                  listen: false)
                              .updateProduct(productToEdit.id, updatedProduct);
                          Navigator.of(ctx).pop();
                          _loadProducts();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Failed to update product: $e')));
                        }
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
      ),
    );
  }

  void _confirmDelete(int index) {
    final product = _farmerProducts[index];
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
              Navigator.of(ctx).pop();
              try {
                await Provider.of<ProductsProvider>(context, listen: false)
                    .deleteProduct(product.id);
                setState(() {
                  _farmerProducts.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting product: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
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
            onPressed: _isLoading ? null : _loadProducts,
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
                  child: _farmerProducts.isEmpty
                      ? Center(
                          child: Text(
                          'You have not added any products yet.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: _farmerProducts.length,
                          itemBuilder: (context, index) {
                            final product = _farmerProducts[index];
                            return _buildProductCard(
                              product: product,
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
    required model.Product product,
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
                if (product.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl,
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
                        product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.farmName,
                        style: const TextStyle(
                          color: Color(0xFF2E603A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.location,
                        style: const TextStyle(
                          color: Color(0xFF2E603A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.category,
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
              '₹${product.price.toStringAsFixed(2)}/${product.unit}',
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
