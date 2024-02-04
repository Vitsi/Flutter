import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

//import 'drawer/saved_code_page.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'QrCodeService.dart';


class GenerateQRCode extends StatelessWidget {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otherController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR Code Generator'), actions: [
        IconButton(
            icon: SvgPicture.asset(
              'svg/white.svg',
              height: 24.0, // Adjust the height as needed
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/MainQR');
              (
                duration: Duration(milliseconds: 500),
                curve: Curves.ease,
              );
            })
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:  ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(labelText: 'Enter Text'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _otherController,
              decoration: InputDecoration(labelText: 'Other(Url)'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Combine the data from different input fields
                String combinedData = "Text: ${_textController.text}\n"
                    "Phone: ${_phoneController.text}\n"
                    "Email: ${_emailController.text}\n"
                    "Other: ${_otherController.text}";
//validate for empty imput
                if (_textController.text.isNotEmpty ||
                    _phoneController.text.isNotEmpty ||
                    _emailController.text.isNotEmpty ||
                    _otherController.text.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DisplayQRCode(combinedData),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Plese enter a non-empty data'),
                  ));
                }
              },
              child: Text('Generate QR Code'),
            ),
          ],
        ),
      ),
    );
  }
}

class DisplayQRCode extends StatelessWidget {
  final String data;

  DisplayQRCode(this.data);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generated QR Code'),
      ),
      body: Center(
        child: QrImageView(
          data: data,
          version: QrVersions.auto,
          size: 250.0,
          foregroundColor: Color.fromARGB(255, 0, 0, 0),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Color.fromARGB(222, 207, 187, 253),
        height: 50,
        items: _icons,
        onTap: (index) async {
          switch (index) {
            case 0:
              _copyToClipboard(data);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copied'),
                ),
              );
              break;
            case 1:
              await _saveQRCode(data, context);
              break;
            case 2:
              _launchURL(data, context);
              break;
            case 3:
              _dialPhoneNumber(data, context);
              break;
            case 4:
              _launchEmail(data, context);
              break;
          }
        },
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  void _launchURL(String url, BuildContext context) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('The generated code is not a URL format'),
      ));
    }
  }

  Future<void> _saveQRCode(String data, BuildContext context) async {
    try {
      // Get the QrCodeService instance from the provider
      QrCodeService qrCodeService =
          Provider.of<QrCodeService>(context, listen: false);

      // Call the sendQRCode method to save the QR code
      await qrCodeService.sendQRCode(context, data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('QR Code saved successfully'),
        ),
      );
    } catch (e) {
      // Handle errors
      print('Error saving QR Code: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save QR Code'),
        ),
      );
    }
  }

  void _dialPhoneNumber(String phoneNumber, BuildContext context) async {
    if (_isValidPhoneNumber(phoneNumber)) {
      final Uri _phoneLaunchUri = Uri(scheme: 'tel', path: phoneNumber);
      await launch(_phoneLaunchUri.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Invalid phone number format. Enter a valid phone number.'),
        ),
      );
    }
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    //regex for ethiopian number
    final RegExp ethiopianPhoneNumberRegExp = RegExp(
        r'(\+\s*2\s*5\s*1\s*9\s*(([0-9]\s*){8}\s*))|(0\s*9\s*(([0-9]\s*){8}))');

    // Check if the phone number matches the regular expression
    if (!ethiopianPhoneNumberRegExp.hasMatch(phoneNumber)) {
      return false;
    }

    // Check if the length of the phone number is at most 10 digits
    return phoneNumber.replaceAll(RegExp(r'[^\d]'), '').length <= 10;
  }

  void _launchEmail(String email, BuildContext context) async {
    if (_isValidEmail(email)) {
      final Uri _emailLaunchUri = Uri(scheme: 'mailto', path: email);
      await launch(_emailLaunchUri.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid email format. Enter a valid email address.'),
        ),
      );
    }
  }

  bool _isValidEmail(String email) {
    // Trim leading and trailing spaces
    email = email.trim();

    if (email.isEmpty) {
      return false; // Empty email is considered invalid
    }

    final RegExp emailRegExp = RegExp(
      // r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      r'',
    );

    // Check if the email matches the regular expression
    return emailRegExp.hasMatch(email);
  }
}

List<Icon> _icons = [
  Icon(Icons.copy),
  Icon(Icons.save),
  Icon(Icons.link),
  Icon(Icons.phone),
  Icon(Icons.email),
];
