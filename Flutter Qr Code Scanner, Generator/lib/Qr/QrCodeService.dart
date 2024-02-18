import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../Qr/drawer/ProfileService.dart';

class QrCodeService {
  final String baseUrl;

  QrCodeService(this.baseUrl);

  Future<void> sendQRCode(BuildContext context, String data) async {
    final apiUrl = '$baseUrl/QRCode';

    String? userToken =
        Provider.of<ProfileService>(context, listen: false).userAccessToken;

    // Make a POST request to save the QR code
    Map<String, dynamic> requestData = {
      'Data': data,
      'CreatedDate': DateTime.now().toIso8601String(),
      //'UserId': userId,
      'UserToken': userToken,
    };
    //to seee the sata being requested in console 
    print('Sending QR Code data to backend: $requestData');

    await http.post(
      Uri.parse(apiUrl),
      body: json.encode(requestData),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
    );
  }

  Future<List<Qr>> getSavedQRCodes(BuildContext context) async {
    final apiUrl = '$baseUrl/QRCode';

    String? userId = Provider.of<ProfileService>(context, listen: false).userId;
    String? userToken =
        Provider.of<ProfileService>(context, listen: false).userAccessToken;

    if (userId == null || userToken == null) {
      print('User ID or Token is null. Cannot fetch QR Codes.');
      return [];
    }

    // Add the user ID to the API request
    final response = await http.get(
      Uri.parse('$apiUrl?userId=$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
    );

    if (response.statusCode == 200) {
      // Parse the JSON response
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Qr.fromJson(json)).toList();
    } else {
      print('Failed to load QR codes. Status Code: ${response.statusCode}');
      return [];
    }
  }

  Future<void> deleteQrCode(context, String id) async {
    String? userToken =
        Provider.of<ProfileService>(context, listen: false).userAccessToken;

    final apiUrl = '$baseUrl/QRCode/$id';

    // Make a DELETE request to delete the QR code
    await http.delete(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
    );
  }
  
  clearAllQRCodes() {}
}

class Qr {
  final String id;
  final String data;
  final DateTime createdDate;
  final String userId;

  Qr({
    required this.id,
    required this.data,
    required this.createdDate,
    required this.userId,
  });

  factory Qr.fromJson(Map<String, dynamic> json) {
    return Qr(
      id: json['id'],
      data: json['data'],
      createdDate: DateTime.parse(json['createdDate']),
      userId: json['userId'],
    );
  }
}

