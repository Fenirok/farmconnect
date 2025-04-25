import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/negotiations_provider.dart';
import '../../models/negotiation.dart';

class NegotiationsScreen extends StatelessWidget {
  static const routeName = '/negotiations';

  const NegotiationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final negotiationsProvider = Provider.of<NegotiationsProvider>(context);
    final activeNegotiations =
        negotiationsProvider.getNegotiationsByStatus('pending');
    final acceptedNegotiations =
        negotiationsProvider.getNegotiationsByStatus('accepted');
    final rejectedNegotiations =
        negotiationsProvider.getNegotiationsByStatus('rejected');

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Negotiations'),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Active (${activeNegotiations.length})'),
              Tab(text: 'Accepted (${acceptedNegotiations.length})'),
              Tab(text: 'Rejected (${rejectedNegotiations.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildNegotiationsList(activeNegotiations, 'pending', context),
            _buildNegotiationsList(acceptedNegotiations, 'accepted', context),
            _buildNegotiationsList(rejectedNegotiations, 'rejected', context),
          ],
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
      itemBuilder: (ctx, i) => NegotiationItem(negotiations[i]),
    );
  }
}

class NegotiationItem extends StatelessWidget {
  final Negotiation negotiation;

  NegotiationItem(this.negotiation);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: Padding(
        padding: EdgeInsets.all(16),
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
                  child: negotiation.imageUrl.isNotEmpty
                      ? Image.network(
                          negotiation.imageUrl,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.image, size: 40),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        negotiation.productName,
                        style: theme.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Farmer: ${negotiation.farmerName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Original Price:',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                'Rs. ${negotiation.originalPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Offer:',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                'Rs. ${negotiation.offeredPrice.toStringAsFixed(2)}',
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
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusChip(negotiation.status),
                Text(
                  negotiation.status == 'pending'
                      ? 'Response by: ${_formatDeadline(negotiation.responseDeadline)}'
                      : negotiation.status == 'accepted'
                          ? 'Final price: Rs. ${negotiation.finalPrice.toStringAsFixed(2)}'
                          : 'Rejected on: ${_formatDate(negotiation.createdAt.add(Duration(days: 1)))}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    IconData iconData;
    String label;

    switch (status) {
      case 'pending':
        chipColor = Colors.blue;
        iconData = Icons.hourglass_empty;
        label = 'Pending';
        break;
      case 'accepted':
        chipColor = Colors.green.shade700;
        iconData = Icons.check_circle;
        label = 'Accepted';
        break;
      case 'rejected':
        chipColor = Colors.red.shade700;
        iconData = Icons.cancel;
        label = 'Rejected';
        break;
      default:
        chipColor = Colors.grey;
        iconData = Icons.help;
        label = 'Unknown';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 16, color: chipColor),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: chipColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
