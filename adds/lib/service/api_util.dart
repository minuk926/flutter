import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/api_response.dart';

class ApiUtil {
  static String host = "http://211.119.124.9:9076";
  static Future<ApiResponse<T>> fetchData<T>({
    required String path,
    required String method,
    required Map<String, dynamic> parameters,
  }) async {
    try {
      
      final url = Uri.parse(host + path);

      late http.Response response;

      if (method.toUpperCase() == 'GET') {
        response = await http.get(
          url.replace(queryParameters: parameters),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        response = await http.post(
          url,
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: parameters,
        );
      }

      //await Future.delayed(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        return ApiResponse(
          success: true,
          code: response.statusCode,
          message: 'Success',
          data: jsonResponse['data'],
          totalCount: jsonResponse['totalCount'] ?? 0,
        );
      } else {
        return ApiResponse(
          success: false,
          code: response.statusCode,
          message: 'Failed to load data',
          data: [] as T, // Cast empty list as T
          totalCount: 0,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        code: 500,
        message: 'Failed to load data',
        data: [] as T, // Cast empty list to generic type T
        totalCount: 0,
      );
    }
  }
}

class CustomLoading extends StatelessWidget {
  final String? message;

  const CustomLoading({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                const SizedBox(height: 15),
                Text(
                  message!,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
