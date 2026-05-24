import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class ApiService {
  // Menggunakan '127.0.0.1' karena kita mengaktifkan ADB reverse port forwarding lewat USB
  static const String _hostIp = '127.0.0.1';

  static String get baseUrl {
    if (kIsWeb) {
      var host = Uri.base.host;
      if (host == 'localhost') {
        host = '127.0.0.1';
      }
      if (host.isNotEmpty) {
        return 'http://$host:9090';
      }
      return 'http://127.0.0.1:9090';
    }
    return 'http://$_hostIp:9090';
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<String?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        String token = response.body;
        if (response.body.startsWith('{')) {
          final data = jsonDecode(response.body);
          token = data['token'] ?? data['accessToken'] ?? response.body;
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        return null; // Success!
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return 'Login gagal: Username atau password salah!';
      } else {
        return 'Server error (Status ${response.statusCode}). Silakan coba lagi.';
      }
    } catch (e) {
      print('Login error: $e');
      return 'Koneksi gagal: $e. Pastikan HP & Laptop terhubung ke Wi-Fi yang sama, server backend aktif, dan IP laptop benar!';
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // ================= STUDENTS API =================
  static Future<List<dynamic>> getStudents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/students/'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error getStudents: $e');
    }
    return [];
  }

  static Future<bool> createStudent(String name, double average) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/students/'),
        headers: await _getHeaders(),
        body: jsonEncode({'name': name, 'average': average}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateStudent(int id, String name, double average) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/students/$id'),
        headers: await _getHeaders(),
        body: jsonEncode({'name': name, 'average': average}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteStudent(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/students/$id'),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  // ================= PROJECTS API =================
  static Future<List<dynamic>> getProjects() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/projects/'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error getProjects: $e');
    }
    return [];
  }

  static Future<bool> createProject({
    required String name,
    PlatformFile? pdfFile,
    PlatformFile? imageFile,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/projects/');
      final request = http.MultipartRequest('POST', uri);
      
      final headers = await _getHeaders();
      request.headers.addAll(headers);
      
      request.fields['name'] = name;
      
      if (pdfFile != null) {
        if (pdfFile.bytes != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'pdf',
            pdfFile.bytes!,
            filename: pdfFile.name,
          ));
        } else if (pdfFile.path != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'pdf',
            pdfFile.path!,
            filename: pdfFile.name,
          ));
        }
      }
      
      if (imageFile != null) {
        if (imageFile.bytes != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'image',
            imageFile.bytes!,
            filename: imageFile.name,
          ));
        } else if (imageFile.path != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'image',
            imageFile.path!,
            filename: imageFile.name,
          ));
        }
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error createProject: $e');
      return false;
    }
  }

  static Future<bool> updateProject({
    required int id,
    required String name,
    PlatformFile? pdfFile,
    PlatformFile? imageFile,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/projects/$id');
      final request = http.MultipartRequest('PUT', uri);
      
      final headers = await _getHeaders();
      request.headers.addAll(headers);
      
      request.fields['name'] = name;
      
      if (pdfFile != null) {
        if (pdfFile.bytes != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'pdf',
            pdfFile.bytes!,
            filename: pdfFile.name,
          ));
        } else if (pdfFile.path != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'pdf',
            pdfFile.path!,
            filename: pdfFile.name,
          ));
        }
      }
      
      if (imageFile != null) {
        if (imageFile.bytes != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'image',
            imageFile.bytes!,
            filename: imageFile.name,
          ));
        } else if (imageFile.path != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'image',
            imageFile.path!,
            filename: imageFile.name,
          ));
        }
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error updateProject: $e');
      return false;
    }
  }

  static Future<bool> deleteProject(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/projects/$id'),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  // ================= ASSIGNMENTS API =================
  static Future<bool> assignProjectToStudent(
    int studentId,
    int projectId, {
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/students/$studentId/projects/$projectId'),
        headers: await _getHeaders(),
        body: jsonEncode({
          if (startDate != null) 'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // ================= CONFIG / SETTINGS API =================
  static Future<int> getMaxProjects() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/students/config/max_projects'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return int.parse(response.body);
      }
    } catch (e) {
      print('Error getMaxProjects: $e');
    }
    return 3; // Default fallback
  }

  static Future<bool> updateMaxProjects(int limit) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/students/config/max_projects'),
        headers: {
          ...await _getHeaders(),
          'Content-Type': 'application/json',
        },
        body: jsonEncode(limit),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updateMaxProjects: $e');
      return false;
    }
  }
}
