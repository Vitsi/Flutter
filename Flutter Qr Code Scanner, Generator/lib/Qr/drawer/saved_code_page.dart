import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../QrCodeService.dart';

class SavedCodesPage extends StatefulWidget {
  @override
  _SavedCodesPageState createState() => _SavedCodesPageState();
}

class _SavedCodesPageState extends State<SavedCodesPage> {
  List<Qr> savedQRCodes = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedQRCodes();
  }

  Future<void> _loadSavedQRCodes() async {
    try {
      QrCodeService qrCodeService =
          Provider.of<QrCodeService>(context, listen: false);
      List<Qr> qrCodes = await qrCodeService.getSavedQRCodes(context);
      // Update the state with the loaded QR codes
      setState(() {
        savedQRCodes = qrCodes;
        loading = false;
      });
    } catch (e) {
      // Handle errors
      print('Error loading saved QR Codes: $e');
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load saved QR Codes'),
        ),
      );
    }
  }

  Future<void> _deleteQrCode(Qr qrCode) async {
    try {
      bool confirmed = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Deletion'),
            content: Text('Are you sure you want to delete this QR Code?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Delete'),
              ),
            ],
          );
        },
      );
      if (confirmed == true) {
        // Get the QrCodeService instance from the provider
        QrCodeService qrCodeService =
            Provider.of<QrCodeService>(context, listen: false);
        await qrCodeService.deleteQrCode(context, qrCode.id);
        await _loadSavedQRCodes();
      }
    } catch (e) {
      print('Error deleting QR Code: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete QR Code'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Saved QR Codes'), actions: [
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
          },
        )
      ]),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : savedQRCodes.isEmpty
              ? Center(child: Text('No saved QR Codes found.'))
              : ListView.builder(
                  itemCount: savedQRCodes.length,
                  itemBuilder: (context, index) {
                    Qr qrCode = savedQRCodes[index];
                    return ListTile(
                      title: Text(qrCode.data),
                      subtitle: Text(
                          'Created on: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(qrCode.createdDate)}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        color: const Color.fromARGB(255, 117, 34, 28),
                        onPressed: () => _deleteQrCode(qrCode),
                        tooltip: 'Delete',
                      ),
                    );
                  },
                ),
    );
  }
}
