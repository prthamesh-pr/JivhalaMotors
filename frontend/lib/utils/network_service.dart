import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/constants.dart';
import 'error_handler.dart';

class NetworkService {
  static const int _timeoutDuration = 30; // seconds

  // Generic API call method
  static Future<Map<String, dynamic>> makeApiCall({
    required String endpoint,
    required String method,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');

      // Default headers
      final defaultHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add authorization token if provided
      if (token != null) {
        defaultHeaders['Authorization'] = 'Bearer $token';
      }

      // Merge with custom headers
      final finalHeaders = {...defaultHeaders, ...?headers};

      if (kDebugMode) {
        print('🌐 API Call: $method $uri');
        print('📋 Headers: $finalHeaders');
        if (body != null) print('📦 Body: $body');
      }

      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(uri, headers: finalHeaders)
              .timeout(const Duration(seconds: _timeoutDuration));
          break;
        case 'POST':
          response = await http
              .post(
                uri,
                headers: finalHeaders,
                body: body != null ? json.encode(body) : null,
              )
              .timeout(const Duration(seconds: _timeoutDuration));
          break;
        case 'PUT':
          response = await http
              .put(
                uri,
                headers: finalHeaders,
                body: body != null ? json.encode(body) : null,
              )
              .timeout(const Duration(seconds: _timeoutDuration));
          break;
        case 'DELETE':
          response = await http
              .delete(uri, headers: finalHeaders)
              .timeout(const Duration(seconds: _timeoutDuration));
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      if (kDebugMode) {
        print('📈 Response Status: ${response.statusCode}');
        print('📄 Response Body: ${response.body}');
      }

      return _handleResponse(response);
    } on SocketException {
      ErrorHandler.logError('Network error: No internet connection');
      throw Exception(
        'No internet connection. Please check your network settings.',
      );
    } on HttpException {
      ErrorHandler.logError('HTTP error occurred');
      throw Exception('Failed to communicate with server.');
    } on FormatException {
      ErrorHandler.logError('Invalid response format');
      throw Exception('Invalid response from server.');
    } catch (e) {
      ErrorHandler.logError(
        'API call failed: $e',
        context: '$method $endpoint',
      );
      rethrow;
    }
  }

  // Handle HTTP response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final responseData = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        final errorMessage =
            responseData['message'] ??
            ErrorHandler.handleApiError(response.statusCode, null);
        throw HttpException(errorMessage);
      }
    } on FormatException {
      throw Exception('Invalid response format from server.');
    }
  }

  // GET request
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    String? token,
  }) async {
    return makeApiCall(
      endpoint: endpoint,
      method: 'GET',
      headers: headers,
      token: token,
    );
  }

  // POST request
  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    String? token,
  }) async {
    return makeApiCall(
      endpoint: endpoint,
      method: 'POST',
      body: body,
      headers: headers,
      token: token,
    );
  }

  // PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    String? token,
  }) async {
    return makeApiCall(
      endpoint: endpoint,
      method: 'PUT',
      body: body,
      headers: headers,
      token: token,
    );
  }

  // DELETE request
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
    String? token,
  }) async {
    return makeApiCall(
      endpoint: endpoint,
      method: 'DELETE',
      headers: headers,
      token: token,
    );
  }

  // Upload file with multipart request
  static Future<Map<String, dynamic>> uploadFile({
    required String endpoint,
    required String filePath,
    required String fieldName,
    Map<String, String>? fields,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add file
      final file = await http.MultipartFile.fromPath(fieldName, filePath);
      request.files.add(file);

      if (kDebugMode) {
        print('📤 Upload: POST $uri');
        print('📁 File: $filePath');
        print('📋 Fields: $fields');
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: _timeoutDuration * 2),
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('📈 Upload Response Status: ${response.statusCode}');
        print('📄 Upload Response Body: ${response.body}');
      }

      return _handleResponse(response);
    } on SocketException {
      ErrorHandler.logError('Network error during file upload');
      throw Exception(
        'No internet connection. Please check your network settings.',
      );
    } catch (e) {
      ErrorHandler.logError('File upload failed: $e', context: endpoint);
      rethrow;
    }
  }

  // Check network connectivity
  static Future<bool> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // Retry mechanism for failed requests
  static Future<Map<String, dynamic>> retryRequest({
    required Future<Map<String, dynamic>> Function() request,
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        return await request();
      } catch (e) {
        attempts++;

        if (attempts >= maxRetries) {
          rethrow;
        }

        ErrorHandler.logError('Request failed (attempt $attempts): $e');
        await Future.delayed(delay * attempts);
      }
    }

    throw Exception('Max retry attempts exceeded');
  }
}
