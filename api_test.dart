import 'dart:io';
import 'dart:convert';

void main() async {
  print('🔄 Testing Jivhala Motors API Connection...\n');

  final client = HttpClient();
  final baseUrl = 'backend-0v1f.onrender.com';

  try {
    // Test 1: Health Check
    print('1️⃣ Testing Health Check...');
    final request = await client.getUrl(Uri.https(baseUrl, '/health'));
    final response = await request.close();

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      print('✅ Health Check: SUCCESS');
      print('   Status: ${response.statusCode}');
      print('   Response: $responseBody');
    } else {
      print('❌ Health Check: FAILED (Status: ${response.statusCode})');
    }
  } catch (e) {
    print('❌ Health Check: FAILED');
    print('   Error: $e');
  }

  print('\n' + '=' * 50 + '\n');

  try {
    // Test 2: Auth endpoint (should return validation error without body)
    print('2️⃣ Testing Auth Endpoint...');
    final request = await client.postUrl(Uri.https(baseUrl, '/api/auth/login'));
    request.headers.set('content-type', 'application/json');
    request.write('{}');
    final response = await request.close();

    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode == 400) {
      print('✅ Auth Endpoint: Expected 400 (Validation error)');
      print('   Status: ${response.statusCode}');
      print('   Response: $responseBody');
    } else {
      print('🔍 Auth Endpoint: Status ${response.statusCode}');
      print('   Response: $responseBody');
    }
  } catch (e) {
    print('❌ Auth Endpoint: FAILED');
    print('   Error: $e');
  }

  print('\n' + '=' * 50 + '\n');

  // Test 3: Test with sample login
  try {
    print('3️⃣ Testing Sample Login...');
    final request = await client.postUrl(Uri.https(baseUrl, '/api/auth/login'));
    request.headers.set('content-type', 'application/json');
    final body = json.encode({
      'username': 'test_user',
      'password': 'test_password',
    });
    request.write(body);
    final response = await request.close();

    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode == 400 || response.statusCode == 401) {
      print('✅ Login Test: Expected error (Invalid credentials)');
      print('   Status: ${response.statusCode}');
      print('   Response: $responseBody');
    } else {
      print('🔍 Login Test: Status ${response.statusCode}');
      print('   Response: $responseBody');
    }
  } catch (e) {
    print('❌ Login Test: FAILED');
    print('   Error: $e');
  }

  client.close();

  print('\n' + '=' * 50);
  print('🎉 API Connection Tests Completed!');
  print('📱 You can now run the Flutter app with confidence.');
  print('📋 Use the Postman collection for detailed API testing.');
  print('=' * 50);
}
