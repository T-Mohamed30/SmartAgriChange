import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../entities/user.dart';
import '../../repository/auth_repository.dart';

class RemoteAuthRepository implements AuthRepository {
  final String baseUrl;
  final Dio dio;

  RemoteAuthRepository({required this.baseUrl, Dio? dioClient})
      : dio = dioClient ?? Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );

  @override
  Future<Map<String, dynamic>?> register(User user) async {
    final url = '$baseUrl/users/farmers/register';
    final requestData = {
      'lastname': user.nom,
      'firstname': user.prenom,
      'phone_number': user.phone,
      'password': user.password,
      'password_confirmation': user.password,
      'calling_code': user.callingCode,
    };

    try {
      final response = await dio.post(
        url,
        data: requestData,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        // Extract token with multiple possible paths - try most common first
        String? token;
        if (responseData['token'] != null) {
          token = responseData['token'];
        } else if (responseData['data']?['token'] != null) {
          token = responseData['data']['token'];
        } else if (responseData['access_token'] != null) {
          token = responseData['access_token'];
        } else if (responseData['data']?['access_token'] != null) {
          token = responseData['data']['access_token'];
        }

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', token);
        }
        // Store user ID for OTP verification - try multiple possible paths
        int? userId;
        if (responseData['data']?['user']?['id'] != null) {
          userId = responseData['data']['user']['id'];
        } else if (responseData['user']?['id'] != null) {
          userId = responseData['user']['id'];
        } else if (responseData['data']?['id'] != null) {
          userId = responseData['data']['id'];
        } else if (responseData['id'] != null) {
          userId = responseData['id'];
        }

        if (userId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', userId);
        }

        // Return user data for OTP verification
        return {
          'user_id': userId,
          'nom': user.nom,
          'prenom': user.prenom,
          'telephone': user.phone,
        };
      } else {
        // Extract validation errors if present
        String errorMessage = 'Erreur lors de l\'inscription';
        if (response.data != null) {
          if (response.data['message'] != null) {
            errorMessage = response.data['message'];
          }
          if (response.data['errors'] != null) {
            final errors = response.data['errors'];
            if (errors is Map) {
              final errorList = errors.values
                  .expand((e) => e is List ? e : [e])
                  .toList();
              errorMessage += ': ${errorList.join(', ')}';
            }
          }
          // Handle Laravel-style validation errors
          if (response.data is Map) {
            response.data.forEach((key, value) {
              if (value is List && value.isNotEmpty) {
                errorMessage += '\n$key: ${value.join(', ')}';
              } else if (value is String) {
                errorMessage += '\n$key: $value';
              }
            });
          }
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> login(String phone, String password, String callingCode) async {
    final url = '$baseUrl/auth/login';
    // Use the provided calling code directly - phone is already just the number
    final phoneNumber = phone;

    try {
      final response = await dio.post(
        url,
        data: {
          'phone_number': phoneNumber,
          'password': password,
          'calling_code': callingCode,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        // Extract token with multiple possible paths - try most common first
        String? token;
        if (responseData['access_token'] != null) {
          token = responseData['access_token'];
        } else if (responseData['data']?['access_token'] != null) {
          token = responseData['data']['access_token'];
        } else if (responseData['token'] != null) {
          token = responseData['token'];
        } else if (responseData['data']?['token'] != null) {
          token = responseData['data']['token'];
        }

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          // Clear any existing token first to ensure fresh login
          await prefs.remove('jwt_token');
          await prefs.setString('jwt_token', token);
          print('Token stored successfully: ${token.substring(0, 20)}...');
        } else {
          print('No token found in login response');
          throw Exception('No token received from server');
        }

        // Extract user data with multiple possible paths
        Map<String, dynamic>? userData;
        if (responseData['user'] != null) {
          userData = responseData['user'];
        } else if (responseData['data']?['user'] != null) {
          userData = responseData['data']['user'];
        }

        // Try to get user data from the root response if user object not found
        if (userData == null && responseData['nom'] != null) {
          userData = responseData;
        }

        if (userData != null) {
          return {
            'nom': userData['lastname'] ?? userData['nom'] ?? '',
            'prenom': userData['firstname'] ?? userData['prenom'] ?? '',
            'telephone': phone,
          };
        }

        // If no user data found, return basic success data
        return {
          'nom': '',
          'prenom': '',
          'telephone': phone,
        };
      } else {

        // Extract validation errors if present
        String errorMessage = 'Échec de la connexion';
        if (response.data != null) {
          if (response.data['message'] != null) {
            errorMessage = response.data['message'];
          }
          if (response.data['errors'] != null) {
            final errors = response.data['errors'];
            if (errors is Map) {
              final errorList = errors.values
                  .expand((e) => e is List ? e : [e])
                  .toList();
              errorMessage += ': ${errorList.join(', ')}';
            }
          }
          // Handle Laravel-style validation errors
          if (response.data is Map) {
            response.data.forEach((key, value) {
              if (value is List && value.isNotEmpty) {
                errorMessage += '\n$key: ${value.join(', ')}';
              } else if (value is String) {
                errorMessage += '\n$key: $value';
              }
            });
          }
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> verifyOtp(
    String phone,
    String otp,
    String nom,
    String prenom,
    String motDePasse, {
    int? userId,
  }) async {
    // Use the provided userId if available, otherwise fall back to SharedPreferences
    int? finalUserId = userId;
    if (finalUserId == null) {
      final prefs = await SharedPreferences.getInstance();
      finalUserId = prefs.getInt('user_id');
    }

    if (finalUserId == null || finalUserId <= 0) {
      throw Exception('User ID not found or invalid. Please register first.');
    }

    final url = '$baseUrl/users/$finalUserId/verify-otp';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('Authentication token not found. Please register again.');
    }

    try {
      final response = await dio.post(
        url,
        data: {'otp_code': otp},
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == 'success' &&
            responseData['message'] == 'OTP verified successfully') {
          return {'nom': nom, 'prenom': prenom, 'telephone': phone};
        } else {
          throw Exception(responseData['message'] ?? 'OTP verification failed');
        }
      } else if (response.statusCode == 400) {
        throw Exception(response.data['message'] ?? 'Invalid OTP code');
      } else if (response.statusCode == 404) {
        throw Exception('User not found or OTP expired');
      } else if (response.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception(
          response.data['message'] ??
              'Échec de la vérification OTP (${response.statusCode})',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('No authentication token found. Please login first.');
    }

    final url = '$baseUrl/auth/me';

    try {
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        // Extract user data with multiple possible paths
        Map<String, dynamic>? userData;
        if (responseData['user'] != null) {
          userData = responseData['user'];
        } else if (responseData['data'] != null) {
          userData = responseData['data'];
        } else if (responseData['nom'] != null || responseData['prenom'] != null) {
          userData = responseData;
        }

        if (userData != null) {
          // Extract user ID for change password functionality
          final userId = userData['id'] ?? userData['user_id'];
          if (userId != null) {
            // Store user ID in SharedPreferences for change password
            await prefs.setInt('user_id', int.parse(userId.toString()));
          }

          return {
            'id': userId,
            'nom': userData['lastname'] ?? userData['nom'] ?? '',
            'prenom': userData['firstname'] ?? userData['prenom'] ?? '',
            'telephone': userData['phone_number'] ?? userData['telephone'] ?? '',
          };
        }

        return null;
      } else {
        throw Exception('Failed to get user profile');
      }
    } catch (e) {
      rethrow;
    }
  }
}
