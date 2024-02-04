// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:provider/provider.dart';

// import 'trialService.dart';

// class SavedCodesPage extends StatefulWidget {
//   @override
//   _SavedCodesPageState createState() => _SavedCodesPageState();
// }

// class _SavedCodesPageState extends State<SavedCodesPage> {
//   List<Qr> savedQRCodes = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedQRCodes();
//   }

//   Future<void> _loadSavedQRCodes() async {
//     try {
//       // Get the QrCodeService instance from the provider
//       QrCodeService qrCodeService =
//           Provider.of<QrCodeService>(context, listen: false);

//       // Call the getSavedQRCodes method to load saved QR codes
//       List<Qr> qrCodes = await qrCodeService.getSavedQRCodes();

//       // Update the state with the loaded QR codes
//       setState(() {
//         savedQRCodes = qrCodes;
//       });
//     } catch (e) {
//       // Handle errors
//       print('Error loading saved QR Codes: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to load saved QR Codes'),
//         ),
//       );
//     }
//   }

//   Future<void> _deleteQrCode(Qr qrCode) async {
//     try {
//       // Show a confirmation dialog
//       bool confirmed = await showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Confirm Deletion'),
//             content: Text('Are you sure you want to delete this QR Code?'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(false),
//                 child: Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(true),
//                 child: Text('Delete'),
//               ),
//             ],
//           );
//         },
//       );

//       // If the user confirms, proceed with deletion
//       if (confirmed == true) {
//         // Get the QrCodeService instance from the provider
//         QrCodeService qrCodeService =
//             Provider.of<QrCodeService>(context, listen: false);
//         // Call the deleteQrCode method to delete the selected QR code
//         await qrCodeService.deleteQrCode(context, qrCode.id);
//         // Reload the saved QR codes after deletion
//         await _loadSavedQRCodes();
//       }
//     } catch (e) {
//       // Handle errors
//       print('Error deleting QR Code: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to delete QR Code'),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Saved QR Codes'), actions: [
//         IconButton(
//             icon: SvgPicture.asset(
//               'svg/white.svg',
//               height: 24.0, 
//             ),
//             onPressed: () {
//               Navigator.pushReplacementNamed(context, '/MainQR');
//               (
//                 duration: Duration(milliseconds: 500),
//                 curve: Curves.ease,
//               );
//             })
//       ]),
//       body: ListView.builder(
//         itemCount: savedQRCodes.length,
//         itemBuilder: (context, index) {
//           Qr qrCode = savedQRCodes[index];
//           return ListTile(
//             title: Text(qrCode.data),
//             subtitle: Text('Created on: ${qrCode.createdDate}'),
//             trailing: IconButton(
//               icon: Icon(Icons.delete),
//               color: const Color.fromARGB(255, 117, 34, 28),
//               onPressed: () => _deleteQrCode(qrCode),
//               tooltip: 'Delete',
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
