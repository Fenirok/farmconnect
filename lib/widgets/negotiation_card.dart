import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/negotiation.dart';
import '../providers/negotiations_provider.dart';
import '../l10n/app_localizations.dart';

class NegotiationCard extends StatelessWidget {
  final Negotiation negotiation;
  final bool isFarmer;

  const NegotiationCard({
    Key? key,
    required this.negotiation,
    required this.isFarmer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final negotiationsProvider =
        Provider.of<NegotiationsProvider>(context, listen: false);

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
                  child: negotiation.imageUrl.isNotEmpty
                      ? Image.network(
                          negotiation.imageUrl,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image, size: 40),
                ),
                const SizedBox(width: 16),
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
                      const SizedBox(height: 4),
                      Text(
                        isFarmer
                            ? 'Consumer: ${negotiation.consumerName}'
                            : 'Farmer: ${negotiation.farmerName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
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
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
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
                                isFarmer ? 'Consumer Offer:' : 'Your Offer:',
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
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusChip(negotiation.status),
                Text(
                  negotiation.status == 'pending'
                      ? 'Response by: ${_formatDeadline(negotiation.responseDeadline)}'
                      : negotiation.status == 'accepted'
                          ? 'Final price: Rs. ${negotiation.finalPrice.toStringAsFixed(2)}'
                          : 'Rejected on: ${_formatDate(negotiation.createdAt.add(const Duration(days: 1)))}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (negotiation.isPending && isFarmer) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        negotiationsProvider.acceptNegotiation(negotiation.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(l10n.accept),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        negotiationsProvider.rejectNegotiation(negotiation.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(l10n.reject),
                  ),
                  ElevatedButton(
                    onPressed: () => _showCounterOfferDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Counter Offer'),
                  ),
                ],
              ),
            ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 16, color: chipColor),
          const SizedBox(width: 4),
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

  void _showCounterOfferDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Counter Offer Price'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            prefixText: '₹',
            hintText: '0.00',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(controller.text);
              if (price != null) {
                Provider.of<NegotiationsProvider>(context, listen: false)
                    .makeCounterOffer(negotiation.id, price);
                Navigator.of(context).pop();
              }
            },
            child: Text(l10n.submit),
          ),
        ],
      ),
    );
  }
}
