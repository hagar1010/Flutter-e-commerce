import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dio = Dio();
      final response = await dio.post(
        'https://ib.jamalmoallart.com/api/v2/login',
        data: FormData.fromMap({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
        options: Options(headers: {'Accept': 'application/json'}),
      );
      print('${json.encode(response.data["data"]["token"])}');
      print('${json.encode(response.data["data"]["token"])}');
      // if (response.statusCode != 200) {
      //   throw Exception('Login failed');
      // }

      final prefs = await SharedPreferences.getInstance();
      // if (_rememberMe) {
      await prefs.setString(
        'token',
        json.encode(response.data["data"]['token']),
      );
      await prefs.setString('user', json.encode(response.data["data"]));
      // }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Login failed: ${e.toString()}')),
        // );

        setState(() {
          _errorMessage = "Email or password is wrong";
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Login', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/img (15).jpg',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.5),
            colorBlendMode: BlendMode.darken,
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white.withOpacity(0.7),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: _inputStyle('Email'),
                          validator: (value) =>
                              value!.isEmpty ? 'Enter email' : null,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          decoration: _inputStyle('Password'),
                          obscureText: true,
                          validator: (value) =>
                              value!.isEmpty ? 'Enter password' : null,
                        ),
                        CheckboxListTile(
                          title: Text('Remember Me'),
                          value: _rememberMe,
                          onChanged: (value) =>
                              setState(() => _rememberMe = value!),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        SizedBox(height: 20),
                        _isLoading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: Colors.blue[300],
                                ),
                                child: Text(
                                  'Login',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/register'),
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
