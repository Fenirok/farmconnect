import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/main_layout.dart';
import '../farmer/widgets/farmer_layout.dart';
import '../l10n/app_localizations.dart';
import '../screens/farmer_registration_screen.dart';
import '../consumer/screens/consumer_login_screen.dart';
import '../consumer/screens/consumer_signup_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;
  String? _selectedState;
  final _kisanIdController = TextEditingController();
  final _aadharIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _consumerPhoneController = TextEditingController();
  final _consumerOtpControllers = List.generate(
    5,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _consumerOtpFocusNodes = List.generate(
    5,
    (index) => FocusNode(),
  );
  bool _showFarmerOtpField = false;
  bool _showConsumerOtpField = false;
  bool _showFarmerVerifyButton = false;
  bool _showConsumerVerifyButton = false;

  final List<String> _states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
  ];

  @override
  void dispose() {
    _kisanIdController.dispose();
    _aadharIdController.dispose();
    _phoneController.dispose();
    _consumerPhoneController.dispose();
    for (var controller in _consumerOtpControllers) {
      controller.dispose();
    }
    for (var node in _consumerOtpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: appLocalizations.selectRole,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildRoleCard(
            role: 'Farmer',
            icon: Icons.agriculture,
            title: appLocalizations.farmer,
            appLocalizations: appLocalizations,
          ),
          const SizedBox(height: 16),
          _buildRoleCard(
            role: 'Consumer',
            icon: Icons.shopping_cart,
            title: appLocalizations.consumer,
            appLocalizations: appLocalizations,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required String role,
    required IconData icon,
    required String title,
    required AppLocalizations appLocalizations,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RadioListTile<String>(
              title: Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.green,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              value: role,
              groupValue: _selectedRole,
              onChanged: (String? value) {
                setState(() {
                  _selectedRole = value;
                  if (value != 'Farmer') {
                    _showFarmerOtpField = false;
                    _showFarmerVerifyButton = false;
                  } else {
                    _showConsumerOtpField = false;
                    _showConsumerVerifyButton = false;
                  }
                });
              },
              activeColor: Colors.green,
              controlAffinity: ListTileControlAffinity.trailing,
            ),
            if (_selectedRole == role) ...[
              const SizedBox(height: 16),
              if (role == 'Farmer') ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/farmer-login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          appLocalizations.login,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, FarmerRegistrationScreen.routeName);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.green),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 16, color: Colors.green),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, ConsumerLoginScreen.routeName);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          appLocalizations.login,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, ConsumerSignupScreen.routeName);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.green),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          appLocalizations.signup,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.green),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOtpFields(
      List<TextEditingController> controllers, List<FocusNode> focusNodes) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        5,
        (index) => SizedBox(
          width: 50,
          child: TextField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 4) {
                focusNodes[index + 1].requestFocus();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAuthenticationFlow({
    required String role,
    required String idType,
    required TextEditingController idController,
    required List<TextEditingController> otpControllers,
    required List<FocusNode> otpFocusNodes,
    required bool showOtpField,
    required bool showVerifyButton,
    required VoidCallback onGenerateOtp,
    required VoidCallback onVerifyOtp,
  }) {
    final appLocalizations = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: DropdownButtonFormField<String>(
            value: _selectedState,
            decoration: InputDecoration(
              labelText: appLocalizations.selectState,
              border: const OutlineInputBorder(),
            ),
            items: _states.map((String state) {
              return DropdownMenuItem<String>(
                value: state,
                child: Text(state),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedState = newValue;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: idController,
            decoration: InputDecoration(
              labelText: idType,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (role == 'Farmer') ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: InputDecoration(
                labelText: appLocalizations.phoneNumber,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onGenerateOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                appLocalizations.generateOTP,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
        if (showOtpField) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildOtpFields(otpControllers, otpFocusNodes),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onVerifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  appLocalizations.verifyOTP,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
        if (showVerifyButton) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => const MainLayout(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  appLocalizations.login,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
