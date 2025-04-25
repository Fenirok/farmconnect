import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../farmer/widgets/farmer_layout.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/connectivity_utils.dart';
import 'dart:io';
import 'dart:async';
import 'farmer_registration_screen.dart';

class FarmerLoginScreen extends StatefulWidget {
  static const String routeName = '/farmer-login';

  const FarmerLoginScreen({Key? key}) : super(key: key);

  @override
  State<FarmerLoginScreen> createState() => _FarmerLoginScreenState();
}

class _FarmerLoginScreenState extends State<FarmerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpSent = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _phone;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final isConnected = await ConnectivityUtils.isConnected();
    setState(() {
      _isConnected = isConnected;
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleOtpVerification() async {
    if (!_isConnected) {
      setState(() {
        _errorMessage = AppLocalizations.of(context).networkError;
      });
      return;
    }

    if (!_isOtpSent) {
      // First time - send OTP
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final phone = '+91${_phoneController.text}';
        _phone = phone; // Store the phone number for later use

        // Check if farmer exists before sending OTP
        final farmer = await SupabaseService().getFarmerByPhone(phone).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception(AppLocalizations.of(context).connectionTimeout);
          },
        );

        if (farmer == null) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(AppLocalizations.of(context).profileNotFound),
                content:
                    Text(AppLocalizations.of(context).noFarmerProfileFound),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(AppLocalizations.of(context).cancel),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.pushNamed(
                          context, FarmerRegistrationScreen.routeName);
                    },
                    child: Text(AppLocalizations.of(context).register),
                  ),
                ],
              ),
            );
          }
          throw Exception(AppLocalizations.of(context).farmerProfileNotFound);
        }

        await SupabaseService().sendOtp(phone: phone).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception(AppLocalizations.of(context).connectionTimeout);
          },
        );

        setState(() {
          _isOtpSent = true;
          _otpController.clear();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(AppLocalizations.of(context).otpSentSuccess)),
          );
        }
      } catch (e) {
        String errorMessage = AppLocalizations.of(context).anErrorOccurred;
        if (e is SocketException ||
            e.toString().contains('Failed host lookup')) {
          errorMessage = AppLocalizations.of(context).networkError;
        } else if (e is TimeoutException) {
          errorMessage = AppLocalizations.of(context).connectionTimeout;
        } else if (e
            .toString()
            .contains(AppLocalizations.of(context).farmerProfileNotFound)) {
          // Don't show the error message again since we already showed the dialog
          return;
        } else {
          errorMessage = e.toString();
        }

        setState(() {
          _errorMessage = errorMessage;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
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
          throw Exception(AppLocalizations.of(context).enterValidOTP);
        }

        // Verify OTP
        await SupabaseService()
            .verifyOtp(
          phone: _phone!,
          token: otp,
        )
            .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception(AppLocalizations.of(context).connectionTimeout);
          },
        );

        // Check if farmer exists again (as a double check)
        final farmer =
            await SupabaseService().getFarmerByPhone(_phone!).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception(AppLocalizations.of(context).connectionTimeout);
          },
        );

        if (farmer == null) {
          throw Exception(AppLocalizations.of(context).farmerProfileNotFound);
        }

        // Navigate to farmer layout
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const FarmerLayout()),
          );
        }
      } catch (e) {
        String errorMessage = AppLocalizations.of(context).anErrorOccurred;
        if (e is SocketException ||
            e.toString().contains('Failed host lookup')) {
          errorMessage = AppLocalizations.of(context).networkError;
        } else if (e is TimeoutException) {
          errorMessage = AppLocalizations.of(context).connectionTimeout;
        } else {
          errorMessage = e.toString();
        }

        setState(() {
          _errorMessage = errorMessage;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected) {
      return ConnectivityUtils.buildNoInternetWidget();
    }

    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: appLocalizations.login),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              ],
              ElevatedButton(
                onPressed: _isLoading ? null : _handleOtpVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(_isOtpSent
                        ? 'Verify OTP'
                        : appLocalizations.generateOTP),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
