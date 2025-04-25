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
    final l10n = AppLocalizations.of(context)!;
    final negotiationsProvider =
        Provider.of<NegotiationsProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              negotiation.productName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              isFarmer ? negotiation.consumerName : negotiation.farmerName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildPriceRow(
                context, l10n.originalPrice, negotiation.originalPrice),
            _buildPriceRow(
                context, l10n.offeredPrice, negotiation.offeredPrice),
            if (negotiation.isCounterOffer)
              _buildPriceRow(context, l10n.counterOffer,
                  negotiation.counterOfferPrice ?? 0.0),
            const SizedBox(height: 16),
            if (negotiation.isPending && isFarmer)
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
              )
            else if (!negotiation.isPending)
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: negotiation.isAccepted
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: negotiation.isAccepted ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Text(
                    negotiation.isAccepted ? l10n.accepted : l10n.rejected,
                    style: TextStyle(
                      color: negotiation.isAccepted
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context, String label, double price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '₹${price.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
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
