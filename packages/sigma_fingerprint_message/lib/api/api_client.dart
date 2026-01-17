import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/fingerprint_settings.dart';
import '../models/message_settings.dart';
import '../models/fingerprint_message_responses.dart';

class ApiClient {
  /// Base API URL
  final String _apiBaseUrl;

  final Map<String, String> _headers;

  ApiClient({required String apiBaseUrl})
    : _apiBaseUrl = apiBaseUrl,
      _headers = {'Content-Type': 'application/json'};

  void setAccessToken(String accessToken) {
    _headers['Authorization'] = 'Bearer $accessToken';
  }

  Future<FPMSettingsResponse> fetchFPMSettings({
    String? channelId,
    Map<String, String> headers = const {},
  }) async {
    try {
      final data = await _makeRequest(
        '/api/v1/configs${channelId?.isNotEmpty == true ? '?channelId=$channelId' : ""}',
        headers: headers,
      );

      // // FIXME: fake response
      // MessageSettings messageSettings = MessageSettings(
      //   bgColor: '#00FFFF',
      //   body: 'Hello, message! ${DateTime.now().toString().hashCode}',
      //   duration: 3,
      //   fontSize: 48,
      //   id: '1234567890',
      //   outputType: MessageOutputType.FORCE_FP,
      //   textColor: '#000000',
      // );
      // FingerprintSettings fingerprintSettings = FingerprintSettings(
      //   displayAt: FPDisplayAtType.AT_POSITION,
      //   displayMAC: false,
      //   duration: 3,
      //   interval: 3,
      //   message: 'Hello, fingerprint! ${DateTime.now().toString().hashCode}',
      //   opacity: 0.8,
      //   outputType: FPOutputType.OVERT,
      //   displayType: FPDisplayType.GLOBAL,
      //   refreshInterval: 30,
      //   repeat: 0,
      //   settings: FingerprintStyleSettings(
      //     bgColor: '#FFFFFF',
      //     displayBackground: false,
      //     fontSize: 14,
      //     px: 10,
      //     py: 10,
      //     textColor: '#000000',
      //   ),
      // );

      return FPMSettingsResponse(
        fingerprintSettings: FingerprintSettings.fromJson(data?["fingerprint"]),
        messageSettings: MessageSettings.fromJson(data?["message"]),
      );
    } catch (e) {
      print('Error fetching message settings: $e');
      return FPMSettingsResponse();
    }
  }

  Future<Map<String, dynamic>?> _makeRequest(
    String endpoint, {
    Map<String, String> headers = const {},
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl$endpoint'),
        headers: {..._headers, ...headers},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint("[ApiCaller] FPM responseData  = $responseData");

        if (responseData is Map &&
            responseData['ec'] == 0 &&
            responseData['data'] != null) {
          return responseData['data'];
        }
      }

      return null;
    } catch (e) {
      print('API request error: $e');
      return null;
    }
  }
}
