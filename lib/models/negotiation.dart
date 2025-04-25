import 'package:flutter/foundation.dart';

class Negotiation {
  final String id;
  final String productName;
  final String imageUrl;
  final String farmerName;
  final String consumerName;
  final double listedPrice;
  final double offerByConsumer;
  final double? offerByFarmer;
  final double? counterOfferPrice;
  final String status; // 'pending', 'accepted', 'rejected', 'counter_offer'
  final DateTime createdAt;

  double get originalPrice => listedPrice;
  double get offeredPrice => offerByConsumer;
  double get finalPrice => offerByFarmer ?? listedPrice;
  DateTime get responseDeadline => createdAt.add(const Duration(hours: 24));

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isCounterOffer => status == 'counter_offer';

  Negotiation({
    required this.id,
    required this.productName,
    required this.imageUrl,
    required this.farmerName,
    this.consumerName = '',
    required this.listedPrice,
    required this.offerByConsumer,
    this.offerByFarmer,
    this.counterOfferPrice,
    required this.status,
    required this.createdAt,
  });

  // Convert Negotiation to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_name': productName,
      'image_url': imageUrl,
      'farm_name': farmerName,
      'consumer_name': consumerName,
      'listed_price': listedPrice,
      'offer_by_consumer': offerByConsumer,
      'offer_by_farmer': offerByFarmer,
      'counter_offer_price': counterOfferPrice,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create Negotiation from Map
  static Negotiation fromMap(Map<String, dynamic> map) {
    return Negotiation(
      id: map['id']?.toString() ?? '',
      productName: map['product_name']?.toString() ?? '',
      imageUrl: map['image_url']?.toString() ?? '',
      farmerName: map['farm_name']?.toString() ?? '',
      consumerName: map['consumer_name']?.toString() ?? '',
      listedPrice: (map['listed_price'] as num?)?.toDouble() ?? 0.0,
      offerByConsumer: (map['offer_by_consumer'] as num?)?.toDouble() ?? 0.0,
      offerByFarmer: map['offer_by_farmer'] != null
          ? (map['offer_by_farmer'] as num).toDouble()
          : null,
      counterOfferPrice: map['counter_offer_price'] != null
          ? (map['counter_offer_price'] as num).toDouble()
          : null,
      status: map['status']?.toString() ?? 'pending',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
    );
  }
}
