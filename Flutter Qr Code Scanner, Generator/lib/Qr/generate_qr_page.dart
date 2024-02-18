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
              height: 24.0,
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
        child: ListView(
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
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Copied'),
                  backgroundColor: Color.fromARGB(230, 52, 7, 83)));
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

  void _launchURL(String combinedData, BuildContext context) async {
    // Extract the URL from the combined data
    String url = _extractUrl(combinedData);

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to launch URL: $url'),
          backgroundColor: Color.fromARGB(230, 83, 7, 36)));
    }
  }

  String _extractUrl(String combinedData) {
    // Split the combined data into lines
    List<String> lines = combinedData.split('\n');
    for (String line in lines) {
      // Check if the line contains  other so it could remove it
      if (line.contains('Other:') &&
          (line.contains('http://') ||
              line.contains('https://') ||
              line.contains('www.'))) {
        List<String> parts = line.split('Other:');
        if (parts.length > 1) {
          return parts[1].trim();
        }
      }
    }
    return 'No link to launch';
  }

  Future<void> _saveQRCode(String data, BuildContext context) async {
    try {
      QrCodeService qrCodeService =
          Provider.of<QrCodeService>(context, listen: false);

      List<Qr> savedQRCodes = await qrCodeService.getSavedQRCodes(context);
      if (savedQRCodes.any((qr) => qr.data == data)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('QR Code already saved'),
              backgroundColor: Color.fromARGB(230, 52, 7, 83)),
        );
      } else {
        await qrCodeService.sendQRCode(context, data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('QR Code saved successfully'),
              backgroundColor: Color.fromARGB(230, 7, 83, 22)),
        );
      }
    } catch (e) {
      // Handle errors
      print('Error saving QR Code: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to save QR Code'),
            backgroundColor: Color.fromARGB(230, 83, 7, 36)),
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
            content: Text(
                'Invalid phone number format. Enter a valid phone number.'),
            backgroundColor: Color.fromARGB(230, 52, 7, 83)),
      );
    }
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    //regex for ethiopian number
    final RegExp ethiopianPhoneNumberRegExp = RegExp(
        r'(\+\s*2\s*5\s*1\s*9\s*(([0-9]\s*){8}\s*))|(0\s*9\s*(([0-9]\s*){8}))');

    if (!ethiopianPhoneNumberRegExp.hasMatch(phoneNumber)) {
      return false;
    }
    return phoneNumber.replaceAll(RegExp(r'[^\d]'), '').length <= 10;
  }

  void _launchEmail(String combinedData, BuildContext context) async {
    String email = _extractEmail(combinedData);

    if (_isValidEmail(email)) {
      final Uri _emailLaunchUri = Uri(scheme: 'mailto', path: email);
      await launch(_emailLaunchUri.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid email format. Enter a valid email address.'),
          backgroundColor: Color.fromARGB(230, 52, 7, 83),
        ),
      );
    }
  }

  String _extractEmail(String combinedData) {
    List<String> lines = combinedData.split('\n');

    for (String line in lines) {
      if (line.contains('Email:')) {
        // Split the line by 'Email:' to get the part after it
        List<String> parts = line.split('Email:');
        if (parts.length > 1) {
          return parts[1].trim();
        }
      }
    }
    return 'No valid email';
  }

  bool _isValidEmail(String email) {
    email = email.trim();

    if (email.isEmpty) {
      return false;
    }

    final RegExp emailRegExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );

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
