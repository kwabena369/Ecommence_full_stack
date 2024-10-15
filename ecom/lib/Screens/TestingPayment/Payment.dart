import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  String _amount = '';
  String _phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make Payment'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Amount (GHS)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) => _amount = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  // You might want to add more specific validation for MTN numbers
                  return null;
                },
                onSaved: (value) => _phoneNumber = value!,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                child: Text('Pay with MTN Mobile Money'),
                onPressed: _initiatePayment,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

void _initiatePayment() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final response = await http.post(
          Uri.parse('https://ecom-node-back.vercel.app/initiate-payment'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'amount': _amount,
            'phoneNumber': _phoneNumber,
          }),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData['status'] == true) {
            if (responseData['data']['status'] == 'send_otp') {
              _showOtpDialog(responseData['data']['display_text'],
                  responseData['data']['reference']);
            } else {
              _showSuccessDialog('Payment initiated successfully');
            }
          } else {
            _showErrorDialog(
                'Payment initiation failed: ${responseData['message']}');
          }
        } else {
          _showErrorDialog('Failed to connect to the server');
        }
      } catch (e) {
        _showErrorDialog('An error occurred: $e');
      }
    }
  }


  void _showOtpDialog(String message, String reference) {
    String otp = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter OTP'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  otp = value;
                },
                decoration: InputDecoration(hintText: "Enter OTP"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop();
                _submitOtp(otp, reference);
              },
            ),
          ],
        );
      },
    );
  }

void _submitOtp(String otp, String reference) async {
    try {
      final response = await http.post(
        Uri.parse('https://ecom-node-back.vercel.app/submit-otp'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'otp': otp,
          'reference': reference,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          _showSuccessDialog('Payment successful');
        } else {
          _showErrorDialog('Payment failed: ${responseData['message']}');
        }
      } else {
        _showErrorDialog('Failed to connect to the server');
      }
    } catch (e) {
      _showErrorDialog('An error occurred: $e');
    }
  }
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                // You might want to navigate back to a previous screen or refresh the current one
                // Navigator.of(context).pop(); // Uncomment this if you want to go back to the previous screen
              },
            ),
          ],
        );
      },
    );
  }
  

  void _showUssdDialog(String ussdCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Complete Payment'),
          content:
              Text('Dial this USSD code to complete your payment: $ussdCode'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
