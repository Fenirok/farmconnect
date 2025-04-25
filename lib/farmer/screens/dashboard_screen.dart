import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/negotiations_provider.dart';
import '../../widgets/negotiation_card.dart';
import '../../l10n/app_localizations.dart';

class DashboardScreen extends StatelessWidget {
  static const routeName = '/farmer-dashboard';

  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final negotiationsProvider = Provider.of<NegotiationsProvider>(context);

    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Remove back button
          title: Text(appLocalizations.dashboard),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appLocalizations.welcomeFarmer,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E603A),
                  ),
                ),
                const SizedBox(height: 24),
                _buildStatCard(
                  title: appLocalizations.totalProducts,
                  value: '24',
                  percentageChange: '+12%',
                  icon: Icons.inventory_2,
                  iconBackgroundColor: const Color(0xFF2E603A),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _showNegotiationsBottomSheet(context),
                  child: _buildStatCard(
                    title: appLocalizations.activeOrders,
                    value: negotiationsProvider
                        .getPendingNegotiationsCount()
                        .toString(),
                    percentageChange: '+25%',
                    icon: Icons.shopping_cart,
                    iconBackgroundColor: Colors.orange,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  title: appLocalizations.monthlySales,
                  value: '₹45,000',
                  percentageChange: '+18%',
                  icon: Icons.trending_up,
                  iconBackgroundColor: Colors.green,
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  title: appLocalizations.salesGrowth,
                  value: '22%',
                  percentageChange: null,
                  icon: Icons.bar_chart,
                  iconBackgroundColor: const Color(0xFF8B4513),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNegotiationsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Negotiations',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(8),
                  children: [
                    _buildNegotiationCard(
                      context,
                      'Fresh Tomatoes',
                      'https://images.unsplash.com/photo-1546094096-0df4bcaaa337',
                      50.0,
                      10.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    String? percentageChange,
    required IconData icon,
    required Color iconBackgroundColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (percentageChange != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          percentageChange,
                          style: TextStyle(
                            fontSize: 14,
                            color: percentageChange.startsWith('+')
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNegotiationCard(
    BuildContext context,
    String productName,
    String imageUrl,
    double originalPrice,
    double offeredPrice,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Listed Price:',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                'Rs. ${originalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Colors.grey,
                                  decorationThickness: 2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Offered Price:',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                'Rs. ${offeredPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showCounterOfferDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: const Text('Counter',
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showAcceptDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Accept'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showRejectDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCounterOfferDialog(BuildContext context) async {
    final counterOfferController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Make Counter Offer'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: counterOfferController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Counter Offer Price (Rs.)',
              prefixText: 'Rs. ',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a price';
              }
              final price = double.tryParse(value);
              if (price == null) {
                return 'Please enter a valid price';
              }
              if (price <= 0) {
                return 'Price must be greater than 0';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAcceptDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Accept Offer'),
        content: const Text('Are you sure you want to accept this offer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRejectDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Offer'),
        content: const Text('Are you sure you want to reject this offer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
