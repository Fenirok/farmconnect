import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/negotiation.dart';

class NegotiationsProvider with ChangeNotifier {
  final _supabaseService = SupabaseService();
  bool _isLoading = false;
  String? _error;
  List<Negotiation> _negotiations = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Negotiation> get negotiations => [..._negotiations];

  Future<void> fetchNegotiations() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final negotiationsData =
          await _supabaseService.getNegotiationsWithDetails();
      _negotiations =
          negotiationsData.map((data) => Negotiation.fromMap(data)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitNegotiation({
    required String productName,
    required String farmName,
    required double listedPrice,
    required double offerByConsumer,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabaseService.submitNegotiation(
        productName: productName,
        farmName: farmName,
        listedPrice: listedPrice,
        offerByConsumer: offerByConsumer,
      );

      await fetchNegotiations(); // Refresh the negotiations list

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  List<Negotiation> getNegotiationsByStatus(String status) {
    return _negotiations
        .where((negotiation) => negotiation.status == status)
        .toList();
  }

  void addNegotiation({
    required String productId,
    required String productName,
    required String imageUrl,
    required String farmerName,
    required double originalPrice,
    required double offeredPrice,
    required Duration responseTime,
  }) {
    final now = DateTime.now();
    final responseDeadline = now.add(responseTime);

    final negotiation = Negotiation(
      id: 'neg_${DateTime.now().millisecondsSinceEpoch}_$productId',
      productName: productName,
      imageUrl: imageUrl,
      farmerName: farmerName,
      listedPrice: originalPrice,
      offerByConsumer: offeredPrice,
      status: 'pending',
      createdAt: now,
    );

    _negotiations.add(negotiation);
    notifyListeners();
  }

  void updateNegotiationStatus(String negotiationId, String status,
      {double? finalPrice}) {
    final index = _negotiations
        .indexWhere((negotiation) => negotiation.id == negotiationId);
    if (index >= 0) {
      final oldNegotiation = _negotiations[index];
      _negotiations[index] = Negotiation(
        id: oldNegotiation.id,
        productName: oldNegotiation.productName,
        imageUrl: oldNegotiation.imageUrl,
        farmerName: oldNegotiation.farmerName,
        listedPrice: oldNegotiation.listedPrice,
        offerByConsumer: oldNegotiation.offerByConsumer,
        offerByFarmer: oldNegotiation.offerByFarmer,
        status: status,
        createdAt: oldNegotiation.createdAt,
      );
      notifyListeners();
    }
  }

  void removeNegotiation(String negotiationId) {
    _negotiations.removeWhere((negotiation) => negotiation.id == negotiationId);
    notifyListeners();
  }

  // Simulates a response from the farmer
  void simulateFarmerResponse(String negotiationId) async {
    final random = Random();
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    final index = _negotiations
        .indexWhere((negotiation) => negotiation.id == negotiationId);
    if (index >= 0) {
      final negotiation = _negotiations[index];

      // 60% chance of acceptance, 40% chance of rejection
      final isAccepted = random.nextDouble() > 0.4;

      if (isAccepted) {
        // Calculate a final price between the original and offered price
        final priceDifference =
            negotiation.listedPrice - negotiation.offerByConsumer;
        final randomFactor =
            random.nextDouble() * 0.7; // Random factor between 0 and 0.7
        final finalPrice =
            negotiation.listedPrice - (priceDifference * randomFactor);

        updateNegotiationStatus(
          negotiationId,
          'accepted',
          finalPrice: double.parse(finalPrice.toStringAsFixed(2)),
        );
      } else {
        updateNegotiationStatus(negotiationId, 'rejected');
      }
    }
  }

  Future<void> acceptNegotiation(String negotiationId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabaseService.updateNegotiationStatus(negotiationId, 'accepted');
      await fetchNegotiations();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> rejectNegotiation(String negotiationId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabaseService.updateNegotiationStatus(negotiationId, 'rejected');
      await fetchNegotiations();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> makeCounterOffer(
      String negotiationId, double counterOfferPrice) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabaseService.submitCounterOffer(
          negotiationId, counterOfferPrice);
      await fetchNegotiations();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Get all pending negotiations
  List<Negotiation> getPendingNegotiations() {
    return _negotiations.where((neg) => neg.status == 'pending').toList();
  }

  // Get count of pending negotiations
  int getPendingNegotiationsCount() {
    return getPendingNegotiations().length;
  }

  // Fetch negotiations for a specific farmer
  Future<List<Negotiation>> fetchFarmerNegotiations() async {
    try {
      final user = _supabaseService.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get the farmer's name from the user metadata
      final farmerName = user.userMetadata?['name'] as String? ?? '';
      print('Fetching negotiations for farmer: $farmerName');

      // First get all negotiations for this farmer
      final negotiations = await _supabaseService.client
          .from('negotiations')
          .select()
          .eq('farm_name', farmerName)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      if (negotiations.isEmpty) {
        return [];
      }

      // Then get all products
      final products = await _supabaseService.client
          .from('product')
          .select('product_name, farm_name, image_url, price')
          .filter('product_name', 'in',
              negotiations.map((n) => n['product_name']).toList());

      // Create a map for quick product lookup
      final productMap = {
        for (var product in products) product['product_name']: product
      };

      // Combine negotiations with product details
      final negotiationsWithDetails = negotiations.map((negotiation) {
        final product = productMap[negotiation['product_name']] ?? {};
        return {
          ...negotiation,
          'image_url': product['image_url'] ?? '',
          'farm_name': product['farm_name'] ?? negotiation['farm_name'],
          'listed_price': product['price'] ?? negotiation['listed_price'],
        };
      }).toList();

      print('Processed negotiations: ${negotiationsWithDetails.length}');
      return negotiationsWithDetails
          .map((data) => Negotiation.fromMap(data))
          .toList();
    } catch (e) {
      print('Error fetching farmer negotiations: $e');
      rethrow;
    }
  }
}
