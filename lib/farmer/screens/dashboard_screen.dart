import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/negotiations_provider.dart';
import '../../widgets/negotiation_card.dart';
import '../../l10n/app_localizations.dart';
import '../../models/negotiation.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/farmer-dashboard';

  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch negotiations when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NegotiationsProvider>(context, listen: false)
          .fetchNegotiations();
    });
  }

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
        body: negotiationsProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
    final negotiationsProvider =
        Provider.of<NegotiationsProvider>(context, listen: false);
    final activeNegotiations =
        negotiationsProvider.getNegotiationsByStatus('pending');
    final acceptedNegotiations =
        negotiationsProvider.getNegotiationsByStatus('accepted');
    final rejectedNegotiations =
        negotiationsProvider.getNegotiationsByStatus('rejected');

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
          child: DefaultTabController(
            length: 3,
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
                        'Negotiations',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon:
                                const Icon(Icons.refresh, color: Colors.white),
                            onPressed: () {
                              Provider.of<NegotiationsProvider>(context,
                                      listen: false)
                                  .fetchNegotiations();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                TabBar(
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  tabs: [
                    Tab(text: 'Active (${activeNegotiations.length})'),
                    Tab(text: 'Accepted (${acceptedNegotiations.length})'),
                    Tab(text: 'Rejected (${rejectedNegotiations.length})'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildNegotiationsList(
                          activeNegotiations, 'pending', context),
                      _buildNegotiationsList(
                          acceptedNegotiations, 'accepted', context),
                      _buildNegotiationsList(
                          rejectedNegotiations, 'rejected', context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNegotiationsList(
      List<Negotiation> negotiations, String status, BuildContext context) {
    if (negotiations.isEmpty) {
      return Center(
        child: Text(
          status == 'pending'
              ? 'No active negotiations yet.'
              : status == 'accepted'
                  ? 'No accepted negotiations yet.'
                  : 'No rejected negotiations yet.',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: negotiations.length,
      itemBuilder: (ctx, i) =>
          NegotiationCard(negotiation: negotiations[i], isFarmer: true),
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
}
