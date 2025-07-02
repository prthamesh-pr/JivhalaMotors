import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/constants.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final List<Map<String, dynamic>> _testResults = [];
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Integration Test'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Backend URL: ${AppConstants.baseUrl}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isRunning ? null : _runTests,
                    child: _isRunning
                        ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Running Tests...'),
                            ],
                          )
                        : const Text('Run API Tests'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _testResults.length,
              itemBuilder: (context, index) {
                final result = _testResults[index];
                final isSuccess = result['success'] as bool;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: Icon(
                      isSuccess ? Icons.check_circle : Icons.error,
                      color: isSuccess ? Colors.green : Colors.red,
                    ),
                    title: Text(result['test'] as String),
                    subtitle: Text(result['message'] as String),
                    trailing: Text(
                      '${result['duration']}ms',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runTests() async {
    setState(() {
      _isRunning = true;
      _testResults.clear();
    });

    await _runTest('Health Check', _testHealthCheck);
    await _runTest('Invalid Login', _testInvalidLogin);
    await _runTest('Get Vehicles (No Auth)', _testGetVehiclesNoAuth);
    await _runTest('Dashboard Stats (No Auth)', _testDashboardStatsNoAuth);

    setState(() {
      _isRunning = false;
    });
  }

  Future<void> _runTest(
    String testName,
    Future<Map<String, dynamic>> Function() testFunction,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await testFunction();
      stopwatch.stop();

      setState(() {
        _testResults.add({
          'test': testName,
          'success': result['success'] ?? false,
          'message': result['message'] ?? 'No message',
          'duration': stopwatch.elapsedMilliseconds,
        });
      });
    } catch (e) {
      stopwatch.stop();
      setState(() {
        _testResults.add({
          'test': testName,
          'success': false,
          'message': 'Exception: $e',
          'duration': stopwatch.elapsedMilliseconds,
        });
      });
    }
  }

  Future<Map<String, dynamic>> _testHealthCheck() async {
    try {
      final response = await ApiService().getDashboardStats();

      if (response['success'] == true || response['statusCode'] == 401) {
        return {'success': true, 'message': 'Backend is reachable'};
      } else {
        return {
          'success': false,
          'message': 'Backend returned: ${response['message']}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection failed: $e'};
    }
  }

  Future<Map<String, dynamic>> _testInvalidLogin() async {
    final result = await ApiService().login(
      'invalid@email.com',
      'wrongpassword',
    );

    if (result['success'] == false) {
      return {'success': true, 'message': 'Correctly rejected invalid login'};
    } else {
      return {
        'success': false,
        'message': 'Should have rejected invalid login',
      };
    }
  }

  Future<Map<String, dynamic>> _testGetVehiclesNoAuth() async {
    final result = await ApiService().getVehicles();

    if (result['success'] == false && result['requiresAuth'] == true) {
      return {'success': true, 'message': 'Correctly requires authentication'};
    } else if (result['success'] == true) {
      return {'success': true, 'message': 'API accessible (no auth required)'};
    } else {
      return {
        'success': false,
        'message': 'Unexpected response: ${result['message']}',
      };
    }
  }

  Future<Map<String, dynamic>> _testDashboardStatsNoAuth() async {
    final result = await ApiService().getDashboardStats();

    if (result['success'] == false && result['requiresAuth'] == true) {
      return {'success': true, 'message': 'Correctly requires authentication'};
    } else if (result['success'] == true) {
      return {'success': true, 'message': 'API accessible (no auth required)'};
    } else {
      return {
        'success': false,
        'message': 'Unexpected response: ${result['message']}',
      };
    }
  }
}
