import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

/// Provider for the ApiClient instance.
///
/// This provider initializes the ApiClient with the base URL from ApiEndpoints.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: ApiEndpoints.baseUrl);
});
