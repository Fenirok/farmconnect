import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/main_layout.dart';
import '../../l10n/app_localizations.dart';
import '../../services/supabase_service.dart';

class ConsumerSignupScreen extends StatefulWidget {
  static const String routeName = '/consumer-signup';

  const ConsumerSignupScreen({Key? key}) : super(key: key);

  @override
  State<ConsumerSignupScreen> createState() => _ConsumerSignupScreenState();
}

class _ConsumerSignupScreenState extends State<ConsumerSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String? _selectedState;
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _phone;

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
    'West Bengal'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _aadhaarController.dispose();
    _addressController.dispose();
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
        final phone = _phoneController.text;
        if (phone.length != 10) {
          throw Exception('Please enter a valid 10-digit phone number');
        }
        _phone = phone;
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
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

  Future<void> _handleSignup() async {
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
      if (formattedPhone.startsWith('91') && formattedPhone.length > 10) {
        formattedPhone = formattedPhone.substring(2);
      }

      // Update user metadata with phone number
      await SupabaseService().updateUserMetadata({
        'phone': formattedPhone,
      });

      final consumerData = {
        'name': _nameController.text,
        'address': _addressController.text,
        'state': _selectedState,
        'aadhaar_id': _aadhaarController.text,
        'phone': formattedPhone,
      };

      await SupabaseService().insertConsumer(consumerData);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainLayout()),
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
      appBar: CustomAppBar(title: appLocalizations.signup),
      body: SingleChildScrollView(
        child: Padding(
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return appLocalizations.enterName;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _aadhaarController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(12),
                  ],
                  decoration: InputDecoration(
                    labelText: appLocalizations.aadharId,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return appLocalizations.enterAadharId;
                    }
                    if (value.length != 12) {
                      return appLocalizations.enterValidAadharId;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: appLocalizations.deliveryAddress,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return appLocalizations.enterValidAddress;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedState,
                  decoration: InputDecoration(
                    labelText: appLocalizations.selectState,
                    border: const OutlineInputBorder(),
                  ),
                  items: _states
                      .map((state) => DropdownMenuItem(
                            value: state,
                            child: Text(state),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() {
                    _selectedState = value;
                  }),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return appLocalizations.selectState;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    labelText: appLocalizations.phoneNumber,
                    border: const OutlineInputBorder(),
                    prefixText: '+91 ',
                  ),
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
                if (!_isOtpSent)
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleOtpVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : Text(appLocalizations.generateOTP),
                  ),
                if (_isOtpSent) ...[
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: InputDecoration(
                      labelText: appLocalizations.verifyOTP,
                      border: const OutlineInputBorder(),
                      errorText: _errorMessage,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleOtpVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Verify OTP'),
                  ),
                  if (_isOtpVerified) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : Text(appLocalizations.signup),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
