import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import 'auth/login_screen.dart';
import 'farmer/farmer_home.dart';
import 'customer/customer_home.dart';

class HomeWrapper extends StatelessWidget {
  const HomeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);

    if (user == null) {
      return LoginScreen();
    } else {
      if (user.role == 'farmer') {
        return FarmerHome();
      } else {
        return CustomerHome();
      }
    }
  }
}
