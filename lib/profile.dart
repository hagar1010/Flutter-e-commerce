import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Map<String, dynamic> _userData;
  bool _isLoading = false;
  bool _isEditing = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _loadUserDataAndImage();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');

    if (userJson != null) {
      setState(() {
        _userData = json.decode(userJson);
        _firstNameController.text = _userData['first_name'] ?? '';
        _lastNameController.text = _userData['last_name'] ?? '';
        _phoneController.text = _userData['phone'] ?? '';
        _addressController.text = _userData['address'] ?? '';
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChangesLocally() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();

    final updatedUser = {
      ..._userData,
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
    };

    await prefs.setString('user', json.encode(updatedUser));

    setState(() {
      _userData = updatedUser;
      _isEditing = false;
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile Updated Successfully')),
    );
  }

  Future<void> _logout(BuildContext context) async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Future<void> _loadUserDataAndImage() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    final imagePath = prefs.getString('profile_image_path');

    if (userJson != null) {
      setState(() {
        _userData = json.decode(userJson);
        // Initialize your controllers here
      });
    }

    if (imagePath != null) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      await prefs.setString('profile_image_path', pickedFile.path);
    }
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: _isEditing ? _pickImage : null,
      child: CircleAvatar(
        radius: 50,
        backgroundImage: _profileImage != null
            ? FileImage(_profileImage!)
            : (_userData['profile_image'] != null
                  ? NetworkImage(_userData['profile_image'])
                  : null),
        child: _profileImage == null && _userData['profile_image'] == null
            ? const Icon(Icons.person, size: 50)
            : null,
      ),
    );
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset controllers to original values when canceling edit
        _firstNameController.text = _userData['first_name'] ?? '';
        _lastNameController.text = _userData['last_name'] ?? '';
        _phoneController.text = _userData['phone'] ?? '';
        _addressController.text = _userData['address'] ?? '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // if (_userData == null) {
    //   return Scaffold(
    //     body: Center(
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           const Text('No user data available'),
    //           TextButton(
    //             onPressed: _loadUserData,
    //             child: const Text('Retry'),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple[200],
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.close : Icons.edit,
              color: Colors.white,
            ),
            onPressed: _toggleEditMode,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // CircleAvatar(
            //   radius: 50,
            //   backgroundImage: _userData['profile_image'] != null
            //       ? NetworkImage(_userData['profile_image'])
            //       : null,
            //   child: _userData['profile_image'] == null
            //       ? const Icon(Icons.person, size: 50)
            //       : null,
            // ),
            _buildProfileImage(),
            const SizedBox(height: 20),

            // Name fields
            _isEditing
                ? Column(
                    children: [
                      TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  )
                : Text(
                    '${_userData['first_name']} ${_userData['last_name']}',
                    // style: Theme.of(context).textTheme.headline6,
                  ),

            const SizedBox(height: 10),
            Text(_userData['email'] ?? 'No email'),
            const SizedBox(height: 20),

            // Phone field
            _isEditing
                ? TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  )
                : ListTile(
                    leading: const Icon(Icons.phone),
                    title: Text(_userData['phone'] ?? 'No phone number'),
                  ),

            const SizedBox(height: 10),

            // Address field
            _isEditing
                ? TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  )
                : ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(_userData['address'] ?? 'No address'),
                  ),

            const SizedBox(height: 20),

            if (_isEditing)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _saveChangesLocally,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[300],
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _toggleEditMode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),

            if (!_isEditing)
              ElevatedButton(
                onPressed: () => _logout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[300],
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
