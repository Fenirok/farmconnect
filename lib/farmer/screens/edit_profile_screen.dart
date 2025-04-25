import 'package:flutter/material.dart';
import 'package:farmconnect/services/supabase_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? farmerData;
  final VoidCallback onProfileUpdated;

  const EditProfileScreen({
    Key? key,
    required this.farmerData,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _stateController;
  late TextEditingController _kisanIdController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.farmerData?['name']);
    _addressController =
        TextEditingController(text: widget.farmerData?['address']);
    _stateController = TextEditingController(text: widget.farmerData?['state']);
    _kisanIdController =
        TextEditingController(text: widget.farmerData?['kisan_id']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _kisanIdController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = SupabaseService().currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final phone = user.phone;
      if (phone == null) {
        throw Exception('Phone number not found');
      }

      await SupabaseService().insertFarmer({
        'name': _nameController.text,
        'phone': phone,
        'address': _addressController.text,
        'state': _stateController.text,
        'kisan_id': _kisanIdController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        widget.onProfileUpdated();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stateController,
              decoration: const InputDecoration(
                labelText: 'State',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your state';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _kisanIdController,
              decoration: const InputDecoration(
                labelText: 'Kisan ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
