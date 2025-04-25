import 'package:flutter/material.dart';
import '../farmer/widgets/farmer_layout.dart';
import 'package:flutter/services.dart';
import '../services/supabase_service.dart';
import '../l10n/app_localizations.dart';

class FarmerRegistrationScreen extends StatefulWidget {
  static const String routeName = '/farmer-registration';

  const FarmerRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<FarmerRegistrationScreen> createState() =>
      _FarmerRegistrationScreenState();
}

class _FarmerRegistrationScreenState extends State<FarmerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedState;
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
  final _kisanIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _phone;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _kisanIdController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleOtpVerification() async {
    if (!_isOtpSent) {
      // First time - send OTP
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final phone = _phoneController.text; // Get the 10-digit number
        if (phone.length != 10) {
          throw Exception('Please enter a valid 10-digit phone number');
        }
        _phone = phone; // Store the phone number for later use
        await SupabaseService().sendOtp(phone: phone);
        setState(() {
          _isOtpSent = true;
          _otpController.clear();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent successfully')),
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
        if (mounted) {
          // Show a dialog with more information
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Phone Verification Required'),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Skip OTP verification for development
                    setState(() {
                      _isOtpVerified = true;
        _isOtpSent = true;
                    });
                  },
                  child: const Text('Continue Anyway'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
    }
  }
    } else {
      // Verify OTP
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final otp = _otpController.text;
        if (otp.length != 6) {
          throw Exception('Please enter a valid 6-digit OTP');
        }

        await SupabaseService().verifyOtp(
          phone: _phone!,
          token: otp,
        );

        setState(() {
          _isOtpVerified = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP verified successfully')),
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _handleSignUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!_isOtpVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify your OTP first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Format phone number to match database format
      String formattedPhone = _phone!;

      // Only remove country code if it's exactly +91 or 91 at the start
      if (_phone!.startsWith('+91') && _phone!.length > 12) {
        formattedPhone = _phone!.substring(3); // Remove +91 prefix
      } else if (_phone!.startsWith('91') && _phone!.length > 11) {
        formattedPhone = _phone!.substring(2); // Remove 91 prefix
      }

      // Ensure we have exactly 10 digits
      if (formattedPhone.length != 10) {
        throw Exception('Invalid phone number format. Must be 10 digits');
      }

      final farmerData = {
        'name': _nameController.text,
        'address': _addressController.text,
        'state': _selectedState,
        'kisan_id': _kisanIdController.text,
        'phone': formattedPhone, // Use the formatted phone number
      };

      await SupabaseService().insertFarmer(farmerData);

      if (mounted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const FarmerLayout()),
    );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.signup),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: appLocalizations.name,
                  border: const OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty
                    ? appLocalizations.enterName
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: appLocalizations.selectState,
                  border: const OutlineInputBorder(),
                ),
                value: _selectedState,
                items: _states
                    .map((st) => DropdownMenuItem(value: st, child: Text(st)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedState = val),
                validator: (val) =>
                    val == null ? appLocalizations.selectState : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: appLocalizations.deliveryAddress,
                  border: const OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty
                    ? appLocalizations.enterValidAddress
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kisanIdController,
                decoration: InputDecoration(
                  labelText: appLocalizations.kisanId,
                  border: const OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty
                    ? appLocalizations.enterKisanId
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: appLocalizations.phoneNumber,
                  border: const OutlineInputBorder(),
                  prefixText: '+91 ',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10)
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return appLocalizations.enterPhoneNumber;
                  }
                  if (value.length != 10) {
                    return appLocalizations.enterValidPhoneNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_isOtpSent) ...[
                TextFormField(
                  controller: _otpController,
                  decoration: InputDecoration(
                    labelText: appLocalizations.verifyOTP,
                    border: const OutlineInputBorder(),
                    errorText: _errorMessage,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6)
                  ],
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _isOtpSent = false;
                            _otpController.clear();
                            _errorMessage = null;
                          });
                        },
                  child: Text(appLocalizations.resendOTP),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleOtpVerification,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Verify OTP'),
                ),
                  const SizedBox(height: 16),
              ],
              if (!_isOtpSent)
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleOtpVerification,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(appLocalizations.generateOTP),
                ),
              const SizedBox(height: 16),
              if (_isOtpVerified)
                  ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignUp,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(appLocalizations.signup),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
