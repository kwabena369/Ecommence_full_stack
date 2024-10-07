import 'package:ecom/Widget/OurInput_Field.dart';
import 'package:flutter/material.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
//   the function is going to be dealing with capturing of the user information
  late String Username = '';
  void _handle_UserName(String value) {
    setState(() {
      Username = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "AuthenticationPage",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color.fromARGB(255, 255, 255, 255),
              shape: BoxShape.rectangle,
              ),
          child: Column(
            children: [
//   the top with the name

              const SizedBox(
                height: 12,
              ),
//   the first instance been the btn that is going to be used
              OurinputField(
                  hintText: "Username",
                  PrefixIcon: Icons.person,
                  onchange: _handle_UserName),
              const SizedBox(
                height: 12,
              ),
//   the first instance been the btn that is going to be used
              OurinputField(
                  hintText: " Email",
                  PrefixIcon: Icons.email,
                  onchange: _handle_UserName),
              const SizedBox(
                height: 12,
              ),
//   the first instance been the btn that is going to be used
              OurinputField(
                  hintText: " Phone",
                  PrefixIcon: Icons.phone,
                  onchange: _handle_UserName)
            ],
          ),
        ),
      ),
    );
  }
}
