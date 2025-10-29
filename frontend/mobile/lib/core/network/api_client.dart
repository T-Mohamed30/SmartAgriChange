import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../exceptions/api_exceptions.dart';
import 'api_endpoints.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? ApiEndpoints.baseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      } else if (kDebugMode) {
        print('No auth token found');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting auth token: $e');
      }
    }

    return headers;
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Request timed out'),
      );
      
      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
      
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('Network error: Unable to connect to the server');
    } on TimeoutException {
      throw TimeoutException('Request timed out');
    } catch (e) {
      if (kDebugMode) {
        print('Error in GET $endpoint: $e');
      }
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, {dynamic body}) async {
    try {
      final headers = await _getHeaders();
      if (kDebugMode) {
        print('POST $baseUrl/$endpoint');
        print('Headers: $headers');
        print('Body: ${jsonEncode(body)}');
      }
      
      final url = _buildUrl(endpoint);
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Request timed out'),
      );
      
      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
      
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('Network error: Unable to connect to the server');
    } on TimeoutException {
      throw TimeoutException('Request timed out');
    } catch (e) {
      if (kDebugMode) {
        print('Error in POST $endpoint: $e');
      }
      rethrow;
    }
  }

  Future<dynamic> put(String endpoint, {dynamic body}) async {
    try {
      final headers = await _getHeaders();
      if (kDebugMode) {
        print('PUT $baseUrl/$endpoint');
        print('Headers: $headers');
        print('Body: ${jsonEncode(body)}');
      }
      
      final url = _buildUrl(endpoint);
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException(),
      );
      
      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
      
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException('Network error: Unable to connect to the server');
    } on TimeoutException {
      throw TimeoutException();
    } catch (e) {
      if (kDebugMode) {
        print('Error in PUT $endpoint: $e');
      }
      rethrow;
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      if (kDebugMode) {
        print('DELETE $baseUrl/$endpoint');
        print('Headers: $headers');
      }
      
      final url = _buildUrl(endpoint);
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException(),
      );
      
      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
      
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException('Network error: Unable to connect to the server');
    } on TimeoutException {
      throw TimeoutException();
    } catch (e) {
      if (kDebugMode) {
        print('Error in DELETE $endpoint: $e');
      }
      rethrow;
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.body.isEmpty) {
      return null;
    }
    
    try {
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseBody;
      }
      
      // Handle error responses
      final errorMessage = responseBody is Map && responseBody.containsKey('message')
          ? responseBody['message']
          : 'Failed to load data: ${response.statusCode}';
          
      if (kDebugMode) {
        print('API Error (${response.statusCode}): $errorMessage');
        print('Response headers: ${response.headers}');
      }
      
      switch (response.statusCode) {
        case 400:
          throw BadRequestException(errorMessage);
        case 401:
          throw UnauthorizedException(errorMessage);
        case 403:
          throw ForbiddenException(errorMessage);
        case 404:
          throw NotFoundException(errorMessage);
        case 408:
          throw TimeoutException(errorMessage);
        case 422:
          throw FormatException(errorMessage);
        case >= 500:
          throw ServerException(errorMessage);
        default:
          throw ApiException(errorMessage, response.statusCode);
      }
    } on FormatException catch (e) {
      if (kDebugMode) {
        print('Failed to parse response: $e');
      }
      throw const FormatException('Invalid response format from server');
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error handling response: $e');
      }
      throw ApiException('An unexpected error occurred', response.statusCode);
    }
  }

  String _buildUrl(String endpoint) {
    if (endpoint.startsWith('http')) {
      return endpoint;
    }
    return '$baseUrl${endpoint.startsWith('/') ? '' : '/'}$endpoint';
  }
}
