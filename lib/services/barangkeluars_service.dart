import 'dart:convert';
import 'package:flutter_api/models/barangkeluars_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BarangKeluarsService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/barangkeluars';

  /// Ambil token dari SharedPreferences
  static Future<Map<String, String>> _getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print('⚠️ Token tidak ditemukan! Pastikan login dulu.');
    }

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// GET: Ambil semua data Barang Keluar
  static Future<BarangKeluars> getBarangKeluars() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);

    print('📡 GET $baseUrl');
    print('🔹 Status: ${response.statusCode}');
    print('🔹 Body: ${response.body}');

    if (response.statusCode == 200) {
      return BarangKeluars.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal mengambil data: ${response.statusCode}');
    }
  }

  /// POST: Tambah Barang Keluar baru
  static Future<bool> createBarangKeluar(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode(data),
    );

    print('📡 POST $baseUrl');
    print('📦 Data: $data');
    print('🔹 Status: ${response.statusCode}');
    print('🔹 Body: ${response.body}');

    return response.statusCode == 201;
  }

  /// PUT: Update Barang Keluar
  static Future<bool> updateBarangKeluar(int id, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
      body: jsonEncode(data),
    );

    print('📡 PUT $baseUrl/$id');
    print('📦 Data: $data');
    print('🔹 Status: ${response.statusCode}');
    print('🔹 Body: ${response.body}');

    return response.statusCode == 200;
  }

  /// DELETE: Hapus Barang Keluar
  static Future<bool> deleteBarangKeluar(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
    );

    print('📡 DELETE $baseUrl/$id');
    print('🔹 Status: ${response.statusCode}');
    print('🔹 Body: ${response.body}');

    return response.statusCode == 200;
  }
}
