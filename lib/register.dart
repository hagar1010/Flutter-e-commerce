import 'package:flutter/material.dart';
import 'dart:convert';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // String? _profileImagePath;
  bool _isLoading = false;

  // Future<void> _pickImage() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() => _profileImagePath = pickedFile.path);
  //   }
  // }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dio = Dio();
      final formData = FormData.fromMap({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'password': _passwordController.text.trim(),
        // if (_profileImagePath != null)
        //   'profile_image': await MultipartFile.fromFile(_profileImagePath!),
      });

      final response = await dio.post(
        'https://ib.jamalmoallart.com/api/v2/register',
        data: formData,
        options: Options(headers: {'Accept': 'application/json'}),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response.data['token']);
      await prefs.setString('user', json.encode(response.data));

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Registration failed: ${e.toString()}')),
      // );
      Navigator.pushReplacementNamed(context, '/login');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white.withOpacity(0.85),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[300],
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Background Image with opacity
          Positioned.fill(
            child: Image.asset(
              'assets/images/img (15).jpg',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.4),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          // Form Content
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // GestureDetector(
                  //   onTap: _pickImage,
                  //   child: CircleAvatar(
                  //     radius: 50,
                  //     backgroundImage: _profileImagePath != null
                  //         ? FileImage(File(_profileImagePath!))
                  //         : null,
                  //     child: _profileImagePath == null
                  //         ? Icon(Icons.add_a_photo, size: 40)
                  //         : null,
                  //   ),
                  // ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: _inputDecoration('First Name'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: _inputDecoration('Last Name'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: _inputDecoration('Email'),
                    validator: (value) => value!.isEmpty || !value.contains('@')
                        ? 'Enter valid email'
                        : null,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    decoration: _inputDecoration('Phone'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: _inputDecoration('Address'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    // maxLines: 2,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    decoration: _inputDecoration('Password'),
                    obscureText: true,
                    validator: (value) => value!.isEmpty || value.length < 6
                        ? 'Minimum 6 characters'
                        : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: _inputDecoration('Confirm Password'),
                    obscureText: true,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: 28),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _register,
                          child: Text('Register'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink[400],
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text(
                          "Log in",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[200],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
