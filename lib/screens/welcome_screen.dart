import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../widgets/custom_app_bar.dart';
import 'role_selection_screen.dart';
import '../l10n/app_localizations.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String? _selectedLanguage;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: appLocalizations.welcome,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              appLocalizations.selectLanguage,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildLanguageRadioTile('English', 'en'),
                _buildLanguageRadioTile('हिंदी', 'hi'),
                _buildLanguageRadioTile('বাংলা', 'bn'),
                _buildLanguageRadioTile('தமிழ்', 'ta'),
                _buildLanguageRadioTile('తెలుగు', 'te'),
                _buildLanguageRadioTile('मराठी', 'mr'),
                _buildLanguageRadioTile('ગુજરાતી', 'gu'),
                _buildLanguageRadioTile('ಕನ್ನಡ', 'kn'),
                _buildLanguageRadioTile('മലയാളം', 'ml'),
                _buildLanguageRadioTile('ਪੰਜਾਬੀ', 'pa'),
                _buildLanguageRadioTile('ଓଡ଼ିଆ', 'or'),
                _buildLanguageRadioTile('অসমীয়া', 'as'),
                _buildLanguageRadioTile('नेपाली', 'ne'),
                _buildLanguageRadioTile('मैथिली', 'mai'),
                _buildLanguageRadioTile('संस्कृतम्', 'sa'),
                _buildLanguageRadioTile('कोंकणी', 'kok'),
                _buildLanguageRadioTile('डोगरी', 'doi'),
                _buildLanguageRadioTile('भोजपुरी', 'bho'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _selectedLanguage == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RoleSelectionScreen(),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
                disabledBackgroundColor: Colors.grey,
              ),
              child: Text(
                appLocalizations.continueButton,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageRadioTile(String languageName, String languageCode) {
    return RadioListTile<String>(
      title: Text(
        languageName,
        style: const TextStyle(fontSize: 20),
      ),
      value: languageCode,
      groupValue: _selectedLanguage,
      onChanged: (String? value) {
        setState(() {
          _selectedLanguage = value;
        });
        Provider.of<LanguageProvider>(context, listen: false)
            .setLanguage(languageCode);
      },
      activeColor: Colors.green,
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}
