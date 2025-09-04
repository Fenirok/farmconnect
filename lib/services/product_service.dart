import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import 'dart:io';

class ProductService {
  // TODO: Replace with your actual Railway backend URL
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  static Future<List<Product>> fetchProducts() async {
    print('Fetching products from: $baseUrl/products');
    final response = await http.get(Uri.parse('$baseUrl/products'));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final products = data.map((json) => Product.fromJson(json)).toList();
      print('Parsed ${products.length} products');
      for (var product in products) {
        print('Product: ${product.name}, FarmerID: ${product.farmerId}');
      }
      return products;
    } else {
      throw Exception('Failed to load products: ${response.body}');
    }
  }

  static Future<String> uploadImage(File imageFile) async {
    const cloudName = 'dbvtdsajz';
    const uploadPreset = 'product_image';

    var uri =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final response = await http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path))
      ..fields['upload_preset'] = uploadPreset;

    final streamedResponse = await response.send();
    final responseBody = await streamedResponse.stream.bytesToString();
    final json = jsonDecode(responseBody);
    return json['secure_url'];
  }

  static Future<Map<String, dynamic>> addProduct(
      Product product, String imageUrl) async {
    var uri = Uri.parse('$baseUrl/farmers/${product.farmerId}/products');

    var response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'category': product.category,
        'farmerId': product.farmerId, // Now already int
        'farmName': product.farmName,
        'weight': product.weight,
        'unit': product.unit,
        'isOrganic': product.isOrganic,
        'location': product.location,
        'imageUrl': imageUrl,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Success - product added
      return {
        'success': true,
        'message': 'Product added successfully',
        'data': jsonDecode(response.body)
      };
    } else if (response.statusCode == 400) {
      // AI validation failed
      final responseBody = jsonDecode(response.body);
      return {
        'success': false,
        'message': responseBody['message'] ?? 'Image validation failed',
        'error': 'AI_VALIDATION_FAILED'
      };
    } else {
      // Other errors
      throw Exception('Failed to add product: ${response.body}');
    }
  }

  static Future<void> updateProduct(String id, Product product) async {
    var uri = Uri.parse('$baseUrl/products/update/$id');
    var response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update product: ${response.body}');
    }
  }

  static Future<void> deleteProduct(String id) async {
    var uri = Uri.parse('$baseUrl/products/delete/$id');
    var response = await http.delete(uri);
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete product: ${response.body}');
    }
  }
}
