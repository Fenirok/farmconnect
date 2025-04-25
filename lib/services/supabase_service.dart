import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path/path.dart' as path;

/// A service class to handle Supabase operations
class SupabaseService {
  // Singleton pattern
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // Supabase client
  late final SupabaseClient client;
  final _connectivity = Connectivity();
  bool _isInitialized = false;

  // Initialize Supabase
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Check network connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('No internet connection available');
      }

      // Verify Supabase URL is reachable
      try {
        await InternetAddress.lookup('onadfszqwosvclurpwww.supabase.co');
      } catch (e) {
        throw Exception(
            'Cannot reach Supabase server. Please check your internet connection and try again.');
      }

      await Supabase.initialize(
        url: 'https://onadfszqwosvclurpwww.supabase.co',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9uYWRmc3pxd29zdmNsdXJwd3d3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUzNTE0MTcsImV4cCI6MjA2MDkyNzQxN30.fXbzabuIyfCYh0YQf4R9NzuNXdoBO0kf1jugkkUp-LA',
        debug: kDebugMode,
      );

      client = Supabase.instance.client;
      _isInitialized = true;
      debugPrint('Supabase initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Supabase: $e');
      rethrow;
    }
  }

  // Ensure client is initialized before use
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  // Authentication methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    await _ensureInitialized();
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    await _ensureInitialized();
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _ensureInitialized();
    await client.auth.signOut();
  }

  // User methods
  User? get currentUser {
    if (!_isInitialized) return null;
    return client.auth.currentUser;
  }

  Future<void> updateUserMetadata(Map<String, dynamic> metadata) async {
    try {
      await _ensureInitialized();
      debugPrint('Updating user metadata: $metadata');

      final user = currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await client.auth.updateUser(
        UserAttributes(
          data: {
            ...user.userMetadata ?? {},
            ...metadata,
          },
        ),
      );

      debugPrint('User metadata updated successfully');
    } catch (e) {
      debugPrint('Error updating user metadata: $e');
      rethrow;
    }
  }

  // Database methods
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      await _ensureInitialized();
      final response = await client
          .from('product')
          .select()
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      debugPrint('Error fetching products: $e');
      rethrow;
    }
  }

  // Phone authentication methods
  Future<void> sendOtp({required String phone}) async {
    try {
      await _ensureInitialized();
      debugPrint('Attempting to send OTP to: $phone');

      // Check network connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('No internet connection available');
      }

      // Format phone number for Supabase auth (E.164 format)
      String formattedPhone = phone;
      if (!phone.startsWith('+')) {
        formattedPhone = '+91$phone';
      }

      // Send OTP
      await client.auth.signInWithOtp(
        phone: formattedPhone,
        shouldCreateUser: true,
      );

      debugPrint('OTP sent successfully to: $phone');
    } catch (e) {
      debugPrint('Error sending OTP to $phone: $e');
      if (e is AuthException) {
        debugPrint('Auth error details: ${e.message}');
        debugPrint('Status code: ${e.statusCode}');

        // Handle Twilio trial account error
        if (e.message.contains('unverified') && e.message.contains('Twilio')) {
          throw Exception(
              'This phone number needs to be verified in the developer account first. Please contact support or try a different number.');
        }
      }

      // Provide more user-friendly error messages
      if (e.toString().contains('No address associated with hostname')) {
        throw Exception(
            'Cannot connect to the server. Please check your internet connection and try again.');
      } else if (e.toString().contains('SocketException')) {
        throw Exception(
            'Network error. Please check your internet connection.');
      }

      rethrow;
    }
  }

  Future<void> resendOtp({required String phone}) async {
    try {
      await _ensureInitialized();
      debugPrint('Attempting to resend OTP to: $phone');
      await sendOtp(phone: phone);
      debugPrint('OTP resent successfully to: $phone');
    } catch (e) {
      debugPrint('Error resending OTP to $phone: $e');
      rethrow;
    }
  }

  Future<AuthResponse> verifyOtp(
      {required String phone, required String token}) async {
    try {
      await _ensureInitialized();
      debugPrint('Attempting to verify OTP for: $phone');

      // Check network connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('No internet connection available');
      }

      // Validate OTP format
      if (token.length != 6) {
        throw Exception('OTP must be 6 digits');
      }

      // Check if the token contains only digits
      if (!RegExp(r'^\d{6}$').hasMatch(token)) {
        throw Exception('OTP must contain only numbers');
      }

      // Format phone number for Supabase auth (E.164 format)
      String formattedPhone = phone;
      if (!phone.startsWith('+')) {
        formattedPhone = '+91$phone';
      }

      final response = await client.auth.verifyOTP(
        phone: formattedPhone,
        token: token,
        type: OtpType.sms,
      );

      debugPrint('OTP verified successfully for: $phone');
      debugPrint('Auth response: ${response.user?.id}');
      return response;
    } catch (e) {
      debugPrint('Error verifying OTP for $phone: $e');

      if (e is AuthException) {
        debugPrint('Auth error details: ${e.message}');
        debugPrint('Status code: ${e.statusCode}');

        // Handle specific OTP-related errors with more user-friendly messages
        if (e.statusCode == 403) {
          if (e.message.contains('expired')) {
            throw Exception('The OTP has expired. Please request a new OTP.');
          } else if (e.message.contains('invalid')) {
            throw Exception(
                'The OTP you entered is incorrect. Please try again.');
          } else {
            throw Exception('OTP verification failed. Please try again.');
          }
        }
      }

      // Provide more user-friendly error messages for network issues
      if (e.toString().contains('No address associated with hostname')) {
        throw Exception(
            'Cannot connect to the server. Please check your internet connection and try again.');
      } else if (e.toString().contains('SocketException')) {
        throw Exception(
            'Network error. Please check your internet connection.');
      }

      // For any other errors, provide a generic message
      throw Exception('Failed to verify OTP. Please try again.');
    }
  }

  // Farmer profile methods
  Future<Map<String, dynamic>?> getFarmerByPhone(String phone) async {
    try {
      await _ensureInitialized();
      debugPrint('Attempting to get farmer by phone: $phone');

      // Format phone number to match database format
      String formattedPhone = phone;

      // Remove any non-digit characters first
      formattedPhone = formattedPhone.replaceAll(RegExp(r'[^\d]'), '');

      // If the number starts with 91 and is longer than 10 digits, remove the 91
      if (formattedPhone.startsWith('91') && formattedPhone.length > 10) {
        formattedPhone = formattedPhone.substring(2);
      }

      // Ensure we have exactly 10 digits
      if (formattedPhone.length != 10) {
        throw Exception('Invalid phone number format. Must be 10 digits');
      }

      debugPrint('Formatted phone for database query: $formattedPhone');

      final response = await client
          .from('farmer')
          .select()
          .eq('phone', formattedPhone)
          .maybeSingle();

      debugPrint('Database response: $response');
      return response;
    } catch (e) {
      debugPrint('Error getting farmer: $e');
      if (e is PostgrestException) {
        debugPrint('Postgrest error details: ${e.message}');
        debugPrint('Error code: ${e.code}');
        debugPrint('Error details: ${e.details}');
      }
      return null;
    }
  }

  Future<void> insertFarmer(Map<String, dynamic> farmerData) async {
    try {
      await _ensureInitialized();
      debugPrint('Attempting to insert farmer data: $farmerData');

      // Verify user is authenticated
      final user = currentUser;
      if (user == null) {
        throw Exception(
            'User must be authenticated before creating farmer profile');
      }

      // Validate required fields
      if (farmerData['name'] == null || farmerData['name'].toString().isEmpty) {
        throw Exception('Name is required');
      }
      if (farmerData['phone'] == null ||
          farmerData['phone'].toString().isEmpty) {
        throw Exception('Phone number is required');
      }
      if (farmerData['state'] == null ||
          farmerData['state'].toString().isEmpty) {
        throw Exception('State is required');
      }

      // Transform the data to match the database schema
      final transformedData = {
        'name': farmerData['name'],
        'address': farmerData['address'] ?? '',
        'state': farmerData['state'],
        'kisan_id': farmerData['kisan_id'] ?? '',
        'phone': farmerData['phone'],
      };

      // Check if farmer profile already exists
      final existingFarmer = await getFarmerByPhone(farmerData['phone']);
      if (existingFarmer != null) {
        throw Exception(
            'A farmer profile already exists with this phone number');
      }

      // Insert the farmer data with RLS enabled
      final response =
          await client.from('farmer').insert(transformedData).select().single();

      if (response != null) {
        debugPrint('Farmer data inserted successfully: $response');
      } else {
        throw Exception('Failed to insert farmer data');
      }
    } catch (e) {
      debugPrint('Error inserting farmer: $e');
      if (e is PostgrestException) {
        debugPrint('Postgrest error details: ${e.message}');
        debugPrint('Error code: ${e.code}');
        debugPrint('Error details: ${e.details}');

        // Handle RLS violation specifically
        if (e.code == '42501') {
          throw Exception(
              'Permission denied. Please make sure you are properly authenticated and have the necessary permissions.');
        }
      }
      rethrow;
    }
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      await _ensureInitialized();
      await client.from('product').insert({
        'product_name': productData['product_name'],
        'farm_name': productData['farm_name'],
        'location': productData['location'],
        'type': productData['type'],
        'price': productData['price'],
        'image_url': productData['image_url'],
      });
    } catch (e) {
      debugPrint('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> updates) async {
    await _ensureInitialized();
    await client.from('products').update(updates).eq('id', id);
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _ensureInitialized();
      await client.from('product').delete().eq('id', id);
    } catch (e) {
      debugPrint('Error deleting product: $e');
      rethrow;
    }
  }

  // Authentication state
  bool get isSignedIn {
    if (!_isInitialized) return false;
    return currentUser != null;
  }

  // Consumer methods
  Future<Map<String, dynamic>?> getConsumerByPhone(String phone) async {
    try {
      await _ensureInitialized();
      debugPrint('Attempting to get consumer by phone: $phone');

      // Format phone number to match database format
      String formattedPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
      if (formattedPhone.startsWith('91') && formattedPhone.length > 10) {
        formattedPhone = formattedPhone.substring(2);
      }

      final response = await client
          .from('consumer')
          .select()
          .eq('phone', formattedPhone)
          .maybeSingle();

      debugPrint('Database response: $response');
      return response;
    } catch (e) {
      debugPrint('Error getting consumer: $e');
      if (e is PostgrestException) {
        debugPrint('Postgrest error details: ${e.message}');
        debugPrint('Error code: ${e.code}');
        debugPrint('Error details: ${e.details}');
      }
      return null;
    }
  }

  Future<void> insertConsumer(Map<String, dynamic> consumerData) async {
    try {
      await _ensureInitialized();
      debugPrint('Attempting to insert consumer data: $consumerData');

      // Verify user is authenticated
      final user = currentUser;
      if (user == null) {
        throw Exception(
            'User must be authenticated before creating consumer profile');
      }

      // Validate required fields
      if (consumerData['name'] == null ||
          consumerData['name'].toString().isEmpty) {
        throw Exception('Name is required');
      }
      if (consumerData['phone'] == null ||
          consumerData['phone'].toString().isEmpty) {
        throw Exception('Phone number is required');
      }
      if (consumerData['state'] == null ||
          consumerData['state'].toString().isEmpty) {
        throw Exception('State is required');
      }
      if (consumerData['aadhaar_id'] == null ||
          consumerData['aadhaar_id'].toString().isEmpty) {
        throw Exception('Aadhaar ID is required');
      }

      // Transform the data to match the database schema
      final transformedData = {
        'name': consumerData['name'],
        'address': consumerData['address'] ?? '',
        'state': consumerData['state'],
        'aadhaar_id': consumerData['aadhaar_id'],
        'phone': consumerData['phone'],
      };

      // Check if consumer profile already exists
      final existingConsumer = await getConsumerByPhone(consumerData['phone']);
      if (existingConsumer != null) {
        throw Exception(
            'A consumer profile already exists with this phone number');
      }

      // Insert the consumer data
      final response = await client
          .from('consumer')
          .insert(transformedData)
          .select()
          .single();

      if (response != null) {
        debugPrint('Consumer data inserted successfully: $response');
      } else {
        throw Exception('Failed to insert consumer data');
      }
    } catch (e) {
      debugPrint('Error inserting consumer: $e');
      if (e is PostgrestException) {
        debugPrint('Postgrest error details: ${e.message}');
        debugPrint('Error code: ${e.code}');
        debugPrint('Error details: ${e.details}');
      }
      rethrow;
    }
  }

  // Storage methods
  Future<String> uploadProductImage(File imageFile, String fileName) async {
    try {
      await _ensureInitialized();
      final String filePath = 'product_images/$fileName';
      await client.storage.from('product-pictures').upload(filePath, imageFile);
      final String publicUrl =
          client.storage.from('product-pictures').getPublicUrl(filePath);
      debugPrint('Uploaded image URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }

  Future<void> deleteProductImage(String imageUrl) async {
    try {
      await _ensureInitialized();
      if (imageUrl.isNotEmpty) {
        final fileName = imageUrl.split('/').last;
        await client.storage
            .from('product-pictures')
            .remove(['product_images/$fileName']);
      }
    } catch (e) {
      debugPrint('Error deleting image: $e');
      rethrow;
    }
  }

  // Negotiation methods
  Future<List<Map<String, dynamic>>> getNegotiationsWithDetails() async {
    try {
      await _ensureInitialized();

      // First get all negotiations
      final negotiations = await client
          .from('negotiations')
          .select()
          .order('created_at', ascending: false);

      if (negotiations.isEmpty) {
        return [];
      }

      // Then get all products
      final products = await client
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

      return negotiationsWithDetails;
    } catch (e) {
      debugPrint('Error fetching negotiations with details: $e');
      rethrow;
    }
  }

  Future<void> submitNegotiation({
    required String productName,
    required String farmName,
    required double listedPrice,
    required double offerByConsumer,
    double? offerByFarmer,
    String status = 'pending',
  }) async {
    try {
      await _ensureInitialized();
      debugPrint('Submitting negotiation for product: $productName');

      final response = await client
          .from('negotiations')
          .insert({
            'product_name': productName,
            'farm_name': farmName,
            'listed_price': listedPrice,
            'offer_by_consumer': offerByConsumer,
            'offer_by_farmer': offerByFarmer,
            'status': status,
          })
          .select()
          .single();

      if (response != null) {
        debugPrint('Negotiation submitted successfully: $response');
      } else {
        throw Exception('Failed to submit negotiation');
      }
    } catch (e) {
      debugPrint('Error submitting negotiation: $e');
      if (e is PostgrestException) {
        debugPrint('Postgrest error details: ${e.message}');
        debugPrint('Error code: ${e.code}');
        debugPrint('Error details: ${e.details}');
      }
      rethrow;
    }
  }

  // Update negotiation status (accept/reject)
  Future<void> updateNegotiationStatus(
      String negotiationId, String status) async {
    try {
      await _ensureInitialized();
      debugPrint('Updating negotiation status: $negotiationId to $status');

      if (!['accepted', 'rejected'].contains(status)) {
        throw Exception(
            'Invalid status. Must be either "accepted" or "rejected"');
      }

      final response = await client
          .from('negotiations')
          .update({'status': status})
          .eq('id', negotiationId)
          .select()
          .single();

      if (response == null) {
        throw Exception('Failed to update negotiation status');
      }

      debugPrint('Negotiation status updated successfully');
    } catch (e) {
      debugPrint('Error updating negotiation status: $e');
      if (e is PostgrestException) {
        debugPrint('Postgrest error details: ${e.message}');
        debugPrint('Error code: ${e.code}');
        debugPrint('Error details: ${e.details}');
      }
      rethrow;
    }
  }

  // Submit counter offer
  Future<void> submitCounterOffer(
      String negotiationId, double counterOfferPrice) async {
    try {
      await _ensureInitialized();
      debugPrint('Submitting counter offer for negotiation: $negotiationId');

      if (counterOfferPrice <= 0) {
        throw Exception('Counter offer price must be greater than 0');
      }

      final response = await client
          .from('negotiations')
          .update({
            'offer_by_farmer': counterOfferPrice,
            'status': 'counter_offered'
          })
          .eq('id', negotiationId)
          .select()
          .single();

      if (response == null) {
        throw Exception('Failed to submit counter offer');
      }

      debugPrint('Counter offer submitted successfully');
    } catch (e) {
      debugPrint('Error submitting counter offer: $e');
      if (e is PostgrestException) {
        debugPrint('Postgrest error details: ${e.message}');
        debugPrint('Error code: ${e.code}');
        debugPrint('Error details: ${e.details}');
      }
      rethrow;
    }
  }
}
