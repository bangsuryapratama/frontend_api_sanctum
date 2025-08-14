import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_api/models/datapusats_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataPusatService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/datapusats';
  static const bool _enableDebugLog = true; // Bisa dimatikan di produksi

  /// Logging helper
  static void _log(String message) {
    if (_enableDebugLog) print(message);
  }

  /// Ambil token dari SharedPreferences
  static Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      _log('Error getting token: $e');
      return null;
    }
  }

  /// Headers umum untuk request JSON
  static Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    final token = await _getToken();
    return {
      if (!isMultipart) HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer ${token ?? ''}',
    };
  }

  /// Fungsi bantu untuk handle HTTP GET dan parsing JSON
  static Future<Map<String, dynamic>> _fetchJson(String url) async {
    try {
      final headers = await _getHeaders();
      _log('GET: $url');
      final response = await http.get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));

      _log('Status Code: ${response.statusCode}');
      _log('Body: ${response.body}');

      if (response.statusCode == 401) {
        throw Exception('Token expired atau tidak valid');
      } else if (response.statusCode == 404) {
        throw Exception('Data tidak ditemukan');
      } else if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      if (response.body.isEmpty) {
        throw Exception('Response kosong dari server');
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } on FormatException {
      throw Exception('Server mengembalikan data tidak valid (bukan JSON)');
    }
  }

  /// List semua DataPusat
  static Future<DataPusat> listDataPusat() async {
    final jsonData = await _fetchJson(baseUrl);
    return DataPusat.fromJson(jsonData);
  }

  /// Detail DataPusat berdasarkan ID
  static Future<DataPusats> showDataPusat(int id) async {
    final jsonData = await _fetchJson('$baseUrl/$id');

    if (jsonData.containsKey('data') && jsonData['data'] != null) {
      return DataPusats.fromJson(jsonData['data']);
    } else if (jsonData.containsKey('id')) {
      return DataPusats.fromJson(jsonData);
    } else {
      throw Exception('Struktur response tidak sesuai yang diharapkan');
    }
  }

  /// Create atau Update DataPusat (shared logic)
  static Future<bool> _sendDataPusat({
    required String method,
    int? id,
    required String kodeBarang,
    required String nama,
    required String merk,
    required int stok,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    if (kodeBarang.trim().isEmpty || nama.trim().isEmpty || merk.trim().isEmpty || stok < 0) {
      throw Exception('Data input tidak valid');
    }

    final token = await _getToken();
    if (token == null || token.isEmpty) throw Exception('Token tidak valid');

    final url = method == 'POST'
        ? baseUrl
        : '$baseUrl/$id?_method=PUT';

    final request = http.MultipartRequest(method == 'POST' ? 'POST' : 'POST', Uri.parse(url))
      ..fields['kode_barang'] = kodeBarang.trim()
      ..fields['nama'] = nama.trim()
      ..fields['merk'] = merk.trim()
      ..fields['stok'] = stok.toString()
      ..headers['Authorization'] = 'Bearer $token';

    if (imageBytes != null && imageName != null && imageName.isNotEmpty) {
      if (imageBytes.length > 5 * 1024 * 1024) {
        throw Exception('Ukuran gambar terlalu besar (maksimal 5MB)');
      }

      final ext = imageName.toLowerCase();
      final contentType = ext.endsWith('.png')
          ? MediaType('image', 'png')
          : MediaType('image', 'jpeg');

      request.files.add(http.MultipartFile.fromBytes(
        'foto',
        imageBytes,
        filename: imageName,
        contentType: contentType,
      ));
    }

    final response = await request.send().timeout(const Duration(seconds: 60));
    final responseBody = await response.stream.bytesToString();

    _log('Send DataPusat - Status: ${response.statusCode}');
    _log('Send DataPusat - Body: $responseBody');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 422) {
      final errorData = jsonDecode(responseBody);
      throw Exception('Data tidak valid: ${errorData['message'] ?? 'Validation error'}');
    } else {
      throw Exception('Gagal memproses data: HTTP ${response.statusCode}');
    }
  }

  /// Create DataPusat baru
  static Future<bool> createDataPusat({
    required String kodeBarang,
    required String nama,
    required String merk,
    required int stok,
    Uint8List? imageBytes,
    String? imageName,
  }) =>
      _sendDataPusat(
        method: 'POST',
        kodeBarang: kodeBarang,
        nama: nama,
        merk: merk,
        stok: stok,
        imageBytes: imageBytes,
        imageName: imageName,
      );

  /// Update DataPusat
  static Future<bool> updateDataPusat({
    required int id,
    required String kodeBarang,
    required String nama,
    required String merk,
    required int stok,
    Uint8List? imageBytes,
    String? imageName,
  }) =>
      _sendDataPusat(
        method: 'PUT',
        id: id,
        kodeBarang: kodeBarang,
        nama: nama,
        merk: merk,
        stok: stok,
        imageBytes: imageBytes,
        imageName: imageName,
      );

  /// Hapus DataPusat
  static Future<bool> deleteDataPusat(int id) async {
    if (id <= 0) throw Exception('ID tidak valid');

    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: headers)
        .timeout(const Duration(seconds: 30));

    _log('Delete DataPusat - Status: ${response.statusCode}');
    _log('Delete DataPusat - Body: ${response.body}');

    if (response.statusCode == 200) return true;
    if (response.statusCode == 404) throw Exception('Data tidak ditemukan');
    if (response.statusCode == 401) throw Exception('Token expired atau tidak valid');

    throw Exception('Gagal menghapus data: ${response.statusCode}');
  }
}
