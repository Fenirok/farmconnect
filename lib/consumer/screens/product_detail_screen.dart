import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/negotiations_provider.dart';
import 'cart_screen.dart';
import 'chat_detail_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  static const routeName = '/product-detail';

  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _negotiationFormKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  String _selectedTimeLimit = '12 hours';
  bool _isNegotiating = false;
  bool _hasNegotiated = false;
  bool _showNegotiationForm = false;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _toggleNegotiationForm() {
    setState(() {
      _showNegotiationForm = !_showNegotiationForm;
    });
  }

  void _submitNegotiation() {
    if (_negotiationFormKey.currentState!.validate()) {
      final product = ModalRoute.of(context)!.settings.arguments as Product;
      final negotiationsProvider =
          Provider.of<NegotiationsProvider>(context, listen: false);
      final offeredPrice = double.parse(_priceController.text);

      setState(() {
        _showNegotiationForm = false;
        _hasNegotiated = true;
      });

      // Show success dialog immediately
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Offer Submitted!'),
          content: Text(
            'Your offer of Rs. ${_priceController.text} has been sent to ${product.farmName}. They will review your offer and respond soon.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

      // Submit the negotiation in the background
      negotiationsProvider
          .submitNegotiation(
        productName: product.name,
        farmName: product.farmName,
        listedPrice: product.price,
        offerByConsumer: offeredPrice,
      )
          .catchError((error) {
        // Show error dialog only if there's an error
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to submit offer: ${error.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as Product;
    final cart = Provider.of<CartProvider>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        // Allow going back to products overview screen
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(product.name),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero image
              Stack(
                children: [
                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child:
                              Icon(Icons.error, size: 50, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  if (product.isOrganic)
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Organic',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Product information section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.unit == 'dozen'
                                    ? 'Rs. ${product.price.toInt()} / dozen'
                                    : 'Rs. ${product.price.toInt()} / ${product.weight}${product.unit}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            cart.addItem(product);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '50 units of ${product.name} added to cart!'),
                                duration: const Duration(seconds: 2),
                                action: SnackBarAction(
                                  label: 'UNDO',
                                  onPressed: () {
                                    cart.removeSingleItem(product.id);
                                  },
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('Add to Cart'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Negotiation section
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Price Negotiation',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (!_hasNegotiated && !_showNegotiationForm)
                                  TextButton.icon(
                                    onPressed: _toggleNegotiationForm,
                                    icon: const Icon(Icons.handshake_outlined),
                                    label: const Text('Negotiate'),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_isNegotiating)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 16),
                                      Text(
                                          'Sending your offer to the farmer...'),
                                    ],
                                  ),
                                ),
                              )
                            else if (_hasNegotiated)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  color: Colors.green.withOpacity(0.1),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        const Icon(Icons.access_time,
                                            color: Colors.orange),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Negotiation in progress',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'The farmer will respond to your offer soon. You will be notified once a response is received.',
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            else if (_showNegotiationForm)
                              Form(
                                key: _negotiationFormKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Make an offer to the farmer. You can negotiate only once per product.',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _priceController,
                                      decoration: const InputDecoration(
                                        labelText: 'Your Price (Rs.)',
                                        border: OutlineInputBorder(),
                                        prefixText: 'Rs. ',
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a price';
                                        }
                                        final price = int.tryParse(value);
                                        if (price == null) {
                                          return 'Please enter a valid price';
                                        }
                                        if (price <= 0) {
                                          return 'Price must be greater than 0';
                                        }
                                        if (price >= product.price) {
                                          return 'Offer must be lower than the original price';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    const Text('Waiting time for response:'),
                                    RadioListTile(
                                      title: const Text('12 hours'),
                                      value: '12 hours',
                                      groupValue: _selectedTimeLimit,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedTimeLimit = value.toString();
                                        });
                                      },
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    RadioListTile(
                                      title: const Text('24 hours'),
                                      value: '24 hours',
                                      groupValue: _selectedTimeLimit,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedTimeLimit = value.toString();
                                        });
                                      },
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        OutlinedButton(
                                          onPressed: _toggleNegotiationForm,
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: _submitNegotiation,
                                          child: const Text('Submit Offer'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            else
                              const Text(
                                'You can negotiate the price directly with the farmer. Make an offer and wait for their response.',
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Rating Section
                    _buildRatingSection(),

                    const SizedBox(height: 20),

                    // Description Section
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Seller Section
                    const Text(
                      'Seller Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.green.shade100,
                              radius: 30,
                              child: Text(
                                product.farmName.substring(0, 1),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.farmName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Local Farmer',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (product.location.isNotEmpty)
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on,
                                            size: 16, color: Colors.green),
                                        const SizedBox(width: 4),
                                        Text(
                                          product.location,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.message_outlined,
                                  color: Colors.green),
                              onPressed: () {
                                // Contact seller functionality
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx) => ChatDetailScreen(
                                      farmerName: product.farmName,
                                      productName: product.name,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Reviews Section
                    _buildReviewsSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    // Mock ratings data
    final rating = 4.5;
    final ratingCount = 28;

    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            if (index < rating.floor()) {
              return const Icon(Icons.star, color: Colors.amber, size: 22);
            } else if (index < rating.ceil() &&
                rating.truncateToDouble() != rating) {
              return const Icon(Icons.star_half, color: Colors.amber, size: 22);
            } else {
              return const Icon(Icons.star_border,
                  color: Colors.amber, size: 22);
            }
          }),
        ),
        const SizedBox(width: 8),
        Text(
          '$rating ($ratingCount reviews)',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    // Mock reviews
    final reviews = [
      {
        'name': 'John Smith',
        'rating': 5,
        'date': '2023-05-15',
        'comment':
            'Excellent quality! The produce was fresh and flavorful. Will definitely buy again.',
      },
      {
        'name': 'Alice Johnson',
        'rating': 4,
        'date': '2023-04-28',
        'comment':
            'Very good quality and value for money. Delivery was a bit delayed.',
      },
      {
        'name': 'Robert Brown',
        'rating': 5,
        'date': '2023-04-10',
        'comment':
            'Outstanding freshness! You can really taste the difference with organic products.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // View all reviews
              },
              child: Text(
                'View All',
                style: TextStyle(
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...reviews.map((review) => _buildReviewItem(review)).toList(),
      ],
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                review['date'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < review['rating'] ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 16,
              );
            }),
          ),
          const SizedBox(height: 4),
          Text(
            review['comment'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
        ],
      ),
    );
  }
}
