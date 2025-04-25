import 'package:flutter/material.dart';
import 'package:farmconnect/screens/welcome_screen.dart';
import 'package:farmconnect/services/supabase_service.dart';
import 'package:farmconnect/utils/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _farmerData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFarmerData();
  }

  Future<void> _loadFarmerData() async {
    try {
      final user = SupabaseService().currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final phone = user.phone;
      if (phone == null) {
        throw Exception('Phone number not found');
      }

      String formattedPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
      if (formattedPhone.startsWith('91') && formattedPhone.length > 10) {
        formattedPhone = formattedPhone.substring(2);
      }

      final farmer = await SupabaseService().getFarmerByPhone(formattedPhone);
      if (farmer == null) {
        throw Exception('Farmer profile not found');
      }

      setState(() {
        _farmerData = farmer;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    try {
      await SupabaseService().signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadFarmerData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFarmerData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Profile Header
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              const CircleAvatar(
                                radius: 50,
                                backgroundColor: AppTheme.primaryColor,
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _farmerData!['name'] ?? 'Not Set',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Farmer ID: ${_farmerData!['kisan_id'] ?? 'Not Set'}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Profile Information
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(
                                'Phone Number',
                                _farmerData!['phone'] ?? 'Not Set',
                                Icons.phone,
                              ),
                              const Divider(),
                              _buildInfoRow(
                                'Address',
                                _farmerData!['address'] ?? 'Not Set',
                                Icons.location_on,
                              ),
                              const Divider(),
                              _buildInfoRow(
                                'State',
                                _farmerData!['state'] ?? 'Not Set',
                                Icons.map,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _handleLogout,
                            icon: const Icon(Icons.logout),
                            label: const Text('Logout'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
