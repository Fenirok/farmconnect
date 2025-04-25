import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/main_layout.dart';
import '../../l10n/app_localizations.dart';
import '../../services/supabase_service.dart';
import 'consumer_signup_screen.dart';

class ConsumerLoginScreen extends StatefulWidget {
  static const String routeName = '/consumer-login';

  const ConsumerLoginScreen({Key? key}) : super(key: key);

  @override
  State<ConsumerLoginScreen> createState() => _ConsumerLoginScreenState();
}

class _ConsumerLoginScreenState extends State<ConsumerLoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  bool _isGeneratingOtp = false;
  bool _isVerifyingOtp = false;
  bool _isLoggingIn = false;
  String? _errorMessage;
  String? _phone;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleOtpVerification() async {
    if (!_isOtpSent) {
      // First time - send OTP
      setState(() {
        _isGeneratingOtp = true;
        _errorMessage = null;
      });

      try {
        final phone = _phoneController.text;
        if (phone.length != 10) {
          throw Exception(AppLocalizations.of(context).enterValidPhoneNumber);
        }
        _phone = phone;

        // Check if consumer exists before sending OTP
        final consumer = await SupabaseService().getConsumerByPhone(phone);
        if (consumer == null) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(AppLocalizations.of(context).profileNotFound),
                content:
                    Text(AppLocalizations.of(context).noConsumerProfileFound),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(AppLocalizations.of(context).cancel),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.pushNamed(
                          context, ConsumerSignupScreen.routeName);
                    },
                    child: Text(AppLocalizations.of(context).signup),
                  ),
                ],
              ),
            );
          }
          throw Exception(AppLocalizations.of(context).consumerProfileNotFound);
        }

        await SupabaseService().sendOtp(phone: phone);
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
        if (e
            .toString()
            .contains(AppLocalizations.of(context).consumerProfileNotFound)) {
          // Don't show the error message again since we already showed the dialog
          return;
        }
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
          setState(() => _isGeneratingOtp = false);
        }
      }
    } else {
      // Verify OTP
      setState(() {
        _isVerifyingOtp = true;
        _errorMessage = null;
      });

      try {
        final otp = _otpController.text;
        if (otp.length != 6) {
          throw Exception(AppLocalizations.of(context).enterValidOTP);
        }

        // Verify OTP
        await SupabaseService().verifyOtp(
          phone: _phone!,
          token: otp,
        );

        // Check if consumer exists again (as a double check)
        final consumer = await SupabaseService().getConsumerByPhone(_phone!);
        if (consumer == null) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(AppLocalizations.of(context).profileNotFound),
                content:
                    Text(AppLocalizations.of(context).noConsumerProfileFound),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(AppLocalizations.of(context).cancel),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.pushNamed(
                          context, ConsumerSignupScreen.routeName);
                    },
                    child: Text(AppLocalizations.of(context).signup),
                  ),
                ],
              ),
            );
          }
          throw Exception(AppLocalizations.of(context).consumerProfileNotFound);
        }

        setState(() {
          _isOtpVerified = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(AppLocalizations.of(context).otpVerifiedSuccess)),
          );
        }
      } catch (e) {
        if (e
            .toString()
            .contains(AppLocalizations.of(context).consumerProfileNotFound)) {
          // Don't show the error message again since we already showed the dialog
          return;
        }
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
          setState(() => _isVerifyingOtp = false);
        }
      }
    }
  }

  Future<void> _handleLogin() async {
    if (!_isOtpVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify your OTP first')),
      );
      return;
    }

    setState(() {
      _isLoggingIn = true;
      _errorMessage = null;
    });

    try {
      // Format phone number to match database format
      String formattedPhone = _phone!;
      if (formattedPhone.startsWith('91') && formattedPhone.length > 10) {
        formattedPhone = formattedPhone.substring(2);
      }

      // Check if consumer exists
      final consumerData =
          await SupabaseService().getConsumerByPhone(formattedPhone);
      if (consumerData == null) {
        throw Exception(AppLocalizations.of(context).consumerProfileNotFound);
      }

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
        setState(() => _isLoggingIn = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: appLocalizations.login),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
              ),
              const SizedBox(height: 16),
              if (!_isOtpSent)
                ElevatedButton(
                  onPressed: _isGeneratingOtp ? null : _handleOtpVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isGeneratingOtp
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
                  onPressed: _isVerifyingOtp ? null : _handleOtpVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isVerifyingOtp
                      ? const CircularProgressIndicator()
                      : const Text('Verify OTP'),
                ),
                if (_isOtpVerified) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoggingIn ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _isLoggingIn
                        ? const CircularProgressIndicator()
                        : Text(appLocalizations.login),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
