// Simple test to verify login functionality
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jivhala_motors/services/api_service.dart';
import 'package:jivhala_motors/providers/auth_provider.dart';

void main() {
  group('Authentication Tests', () {
    test('API Service Login Test', () async {
      final apiService = ApiService();
      apiService.initialize();

      try {
        final response = await apiService.login('demo', 'demo123');

        expect(response['token'], isNotNull);
        expect(response['user'], isNotNull);
        expect(response['message'], equals('Login successful'));

        debugPrint('✅ API Login Test Passed');
        debugPrint('Token: ${response['token']?.substring(0, 20)}...');
        debugPrint('User: ${response['user']['name']}');
      } catch (e) {
        debugPrint('❌ API Login Test Failed: $e');
        fail('Login test failed: $e');
      }
    });

    test('Auth Provider Login Test', () async {
      final authProvider = AuthProvider();

      try {
        final success = await authProvider.login('demo', 'demo123');

        expect(success, isTrue);
        expect(authProvider.user, isNotNull);
        expect(authProvider.token, isNotNull);
        expect(authProvider.isAuthenticated, isTrue);

        debugPrint('✅ Auth Provider Login Test Passed');
        debugPrint('User: ${authProvider.user?.name}');
        debugPrint('Role: ${authProvider.user?.role}');
      } catch (e) {
        debugPrint('❌ Auth Provider Login Test Failed: $e');
        fail('Auth provider test failed: $e');
      }
    });
  });
}
