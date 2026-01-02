import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String name = '';
  String role = 'customer'; // Default role
  String error = '';

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Sign Up for Tokri')),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 20.0),
                TextFormField(
                  decoration: InputDecoration(hintText: 'Name'),
                  onChanged: (val) {
                    setState(() => name = val);
                  },
                  validator: (val) => val!.isEmpty ? 'Enter your name' : null,
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  decoration: InputDecoration(hintText: 'Email'),
                  onChanged: (val) {
                    setState(() => email = val);
                  },
                  validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  decoration: InputDecoration(hintText: 'Password'),
                  obscureText: true,
                  onChanged: (val) {
                    setState(() => password = val);
                  },
                  validator: (val) => val!.length < 6 ? 'Enter a password 6+ chars long' : null,
                ),
                SizedBox(height: 20.0),
                DropdownButtonFormField(
                  initialValue: role,
                  items: [
                    DropdownMenuItem(value: "customer", child: Text("Customer")),
                    DropdownMenuItem(value: "farmer", child: Text("Farmer")),
                  ],
                  onChanged: (val) {
                    setState(() => role = val.toString());
                  },
                  decoration: InputDecoration(labelText: "I am a:"),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  child: Text('Register'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      dynamic result = await authService.signUp(
                        email: email, 
                        password: password,
                        role: role,
                        name: name
                      );
                      if (result == null) {
                        Navigator.pop(context); // Go back to login or auto-login handled by stream
                      } else {
                        setState(() => error = result);
                      }
                    }
                  },
                ),
                SizedBox(height: 12.0),
                Text(
                  error,
                  style: TextStyle(color: Colors.red, fontSize: 14.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
