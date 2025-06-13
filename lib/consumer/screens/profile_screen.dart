import 'package:flutter/material.dart';
import '../../screens/welcome_screen.dart';
import 'orders_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _consumerData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchConsumerData();
  }

  Future<void> _fetchConsumerData() async {
    try {
      debugPrint('Starting to fetch consumer data...');

      // Get the current user
      final user = SupabaseService().currentUser;
      debugPrint('Current user: ${user?.id}');

      if (user == null) {
        throw Exception('User not authenticated. Please login again.');
      }

      // Get the phone number from the user's metadata
      final phone = user.userMetadata?['phone'] as String?;
      debugPrint('Phone from metadata: $phone');

      if (phone == null) {
        throw Exception('Phone number not found in user metadata');
      }

      // Format phone number to match database format
      String formattedPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
      if (formattedPhone.startsWith('91') && formattedPhone.length > 10) {
        formattedPhone = formattedPhone.substring(2);
      }
      debugPrint('Formatted phone for query: $formattedPhone');

      // Fetch consumer data using the phone number
      final consumerData =
          await SupabaseService().getConsumerByPhone(formattedPhone);
      debugPrint('Fetched consumer data: $consumerData');

      if (consumerData == null) {
        throw Exception(
            'Consumer profile not found. Please complete your profile setup.');
      }

      setState(() {
        _consumerData = consumerData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching consumer data: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(appLocalizations.myProfile),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchConsumerData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchConsumerData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProfileHeader(context),
                      const Divider(),
                      _buildMenuSection(context),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.green,
            child: Text(
              _getInitials(_consumerData?['name'] ?? ''),
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _consumerData?['name'] ?? '',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _consumerData?['address'] ?? '',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '+91 ${_consumerData?['phone'] ?? ''}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Text(
                    '0', // TODO: Fetch actual order count
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    appLocalizations.orders,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                height: 30,
                child: VerticalDivider(
                  color: Colors.grey[300],
                  thickness: 1,
                  width: 40,
                ),
              ),
              Column(
                children: [
                  const Text(
                    '0', // TODO: Fetch actual negotiations count
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    appLocalizations.negotiations,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                height: 30,
                child: VerticalDivider(
                  color: Colors.grey[300],
                  thickness: 1,
                  width: 40,
                ),
              ),
              Column(
                children: [
                  const Text(
                    '0', // TODO: Fetch actual favorites count
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    appLocalizations.favorites,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          _buildMenuItem(
            context,
            icon: Icons.local_shipping_outlined,
            title: appLocalizations.myOrders,
            onTap: () {
              Navigator.of(context).pushNamed(OrdersScreen.routeName);
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.location_on_outlined,
            title: appLocalizations.myAddresses,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(appLocalizations.addressesFeature),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.favorite_border,
            title: appLocalizations.myFavorites,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(appLocalizations.favoritesFeature),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.payment_outlined,
            title: appLocalizations.paymentMethods,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(appLocalizations.paymentMethodsFeature),
                ),
              );
            },
          ),
          const Divider(),
          _buildMenuItem(
            context,
            icon: Icons.help_outline,
            title: appLocalizations.helpAndSupport,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(appLocalizations.helpFeature),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.settings_outlined,
            title: appLocalizations.settings,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(appLocalizations.settingsFeature),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.logout,
            title: appLocalizations.logout,
            textColor: Colors.red,
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(appLocalizations.logout),
                  content: Text(appLocalizations.logoutConfirmation),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Text(appLocalizations.cancel),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        try {
                          await SupabaseService().signOut();
                          if (mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const WelcomeScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Error signing out: ${e.toString()}'),
                              ),
                            );
                          }
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: Text(appLocalizations.logout),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.grey[800],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }
}
