import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_api/models/datapusats_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataPusatService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/datapusats';

  // Ambil token dari SharedPreferences
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  // Headers dengan error handling
  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer ${token ?? ''}',
    };
  }

  // List semua DataPusat
  static Future<DataPusat> listDataPusat() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      print('List DataPusat - Status Code: ${response.statusCode}');
      print('List DataPusat - Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Cek apakah response body kosong
        if (response.body.isEmpty) {
          throw Exception('Server mengembalikan response kosong');
        }
        
        final jsonData = jsonDecode(response.body);
        return DataPusat.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw Exception('Token expired atau tidak valid');
      } else {
        throw Exception('Gagal mengambil data pusat: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } on FormatException catch (e) {
      print('JSON Format Error: $e');
      throw Exception('Server mengembalikan data yang tidak valid (bukan JSON)');
    } catch (e) {
      print('Error in listDataPusat: $e');
      throw Exception('Gagal mengambil data: $e');
    }
  }

  // Detail DataPusat berdasarkan ID - FIXED VERSION
  static Future<DataPusats> showDataPusat(int id) async {
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl/$id';
      
      print('Fetching detail for ID: $id');
      print('URL: $url');
      print('Headers: $headers');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      print('Detail DataPusat - Status Code: ${response.statusCode}');
      print('Detail DataPusat - Response Body: ${response.body}');
      print('Detail DataPusat - Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        // Cek apakah response body kosong
        if (response.body.isEmpty) {
          throw Exception('Server mengembalikan response kosong');
        }

        // Cek apakah response adalah JSON yang valid
        late Map<String, dynamic> jsonData;
        try {
          jsonData = jsonDecode(response.body);
        } catch (e) {
          print('JSON Parse Error: $e');
          print('Response Body: ${response.body}');
          throw Exception('Server mengembalikan data yang tidak valid (bukan JSON)');
        }

        print('Parsed JSON: $jsonData');

        // Cek struktur response
        if (jsonData.containsKey('data') && jsonData['data'] != null) {
          // Response dengan wrapper 'data'
          return DataPusats.fromJson(jsonData['data']);
        } else if (jsonData.containsKey('id')) {
          // Response langsung object data
          return DataPusats.fromJson(jsonData);
        } else {
          print('JSON Structure: ${jsonData.keys}');
          throw Exception('Struktur response tidak sesuai yang diharapkan');
        }
        
      } else if (response.statusCode == 401) {
        throw Exception('Token expired atau tidak valid');
      } else if (response.statusCode == 404) {
        throw Exception('Data dengan ID $id tidak ditemukan');
      } else {
        throw Exception('Gagal mengambil detail data: HTTP ${response.statusCode}\nResponse: ${response.body}');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } on FormatException catch (e) {
      print('JSON Format Error: $e');
      throw Exception('Server mengembalikan data yang tidak valid (bukan JSON)');
    } catch (e) {
      print('Error in showDataPusat: $e');
      rethrow; // Re-throw untuk mempertahankan error message yang sudah di-handle
    }
  }

  // Create DataPusat baru
  static Future<bool> createDataPusat({
    required String kodeBarang,
    required String nama,
    required String merk,
    required int stok,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak valid');
      }

      final request = http.MultipartRequest('POST', Uri.parse(baseUrl));

      // Validasi input
      if (kodeBarang.trim().isEmpty || 
          nama.trim().isEmpty || 
          merk.trim().isEmpty || 
          stok < 0) {
        throw Exception('Data input tidak valid');
      }

      request.fields['kode_barang'] = kodeBarang.trim();
      request.fields['nama'] = nama.trim();
      request.fields['merk'] = merk.trim();
      request.fields['stok'] = stok.toString();

      if (imageBytes != null && imageName != null && imageName.isNotEmpty) {
        // Validasi ukuran file (maksimal 5MB)
        if (imageBytes.length > 5 * 1024 * 1024) {
          throw Exception('Ukuran gambar terlalu besar (maksimal 5MB)');
        }

        // Tentukan content type berdasarkan ekstensi
        MediaType contentType = MediaType('image', 'jpeg');
        if (imageName.toLowerCase().endsWith('.png')) {
          contentType = MediaType('image', 'png');
        } else if (imageName.toLowerCase().endsWith('.jpg') || 
                   imageName.toLowerCase().endsWith('.jpeg')) {
          contentType = MediaType('image', 'jpeg');
        }

        request.files.add(
          http.MultipartFile.fromBytes(
            'foto',
            imageBytes,
            filename: imageName,
            contentType: contentType,
          ),
        );
      }

      request.headers['Authorization'] = 'Bearer $token';

      final response = await request.send().timeout(const Duration(seconds: 60));
      final responseBody = await response.stream.bytesToString();
      
      print('Create DataPusat - Status Code: ${response.statusCode}');
      print('Create DataPusat - Response Body: $responseBody');
      
      if (response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Token expired atau tidak valid');
      } else if (response.statusCode == 422) {
        try {
          final errorData = jsonDecode(responseBody);
          throw Exception('Data tidak valid: ${errorData['message'] ?? 'Validation error'}');
        } catch (e) {
          throw Exception('Data tidak valid: $responseBody');
        }
      } else {
        throw Exception('Gagal membuat data: ${response.statusCode}\nResponse: $responseBody');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } catch (e) {
      print('Error in createDataPusat: $e');
      rethrow;
    }
  }

  // Update DataPusat
  static Future<bool> updateDataPusat({
    required int id,
    required String kodeBarang,
    required String nama,
    required String merk,
    required int stok,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak valid');
      }

      if (id <= 0) {
        throw Exception('ID tidak valid');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/$id?_method=PUT'),
      );

      // Validasi input
      if (kodeBarang.trim().isEmpty || 
          nama.trim().isEmpty || 
          merk.trim().isEmpty || 
          stok < 0) {
        throw Exception('Data input tidak valid');
      }

      request.fields['kode_barang'] = kodeBarang.trim();
      request.fields['nama'] = nama.trim();
      request.fields['merk'] = merk.trim();
      request.fields['stok'] = stok.toString();

      if (imageBytes != null && imageName != null && imageName.isNotEmpty) {
        // Validasi ukuran file (maksimal 5MB)
        if (imageBytes.length > 5 * 1024 * 1024) {
          throw Exception('Ukuran gambar terlalu besar (maksimal 5MB)');
        }

        // Tentukan content type berdasarkan ekstensi
        MediaType contentType = MediaType('image', 'jpeg');
        if (imageName.toLowerCase().endsWith('.png')) {
          contentType = MediaType('image', 'png');
        } else if (imageName.toLowerCase().endsWith('.jpg') || 
                   imageName.toLowerCase().endsWith('.jpeg')) {
          contentType = MediaType('image', 'jpeg');
        }

        request.files.add(
          http.MultipartFile.fromBytes(
            'foto',
            imageBytes,
            filename: imageName,
            contentType: contentType,
          ),
        );
      }

      request.headers['Authorization'] = 'Bearer $token';

      final response = await request.send().timeout(const Duration(seconds: 60));
      final responseBody = await response.stream.bytesToString();
      
      print('Update DataPusat - Status Code: ${response.statusCode}');
      print('Update DataPusat - Response Body: $responseBody');
      
      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Token expired atau tidak valid');
      } else if (response.statusCode == 404) {
        throw Exception('Data tidak ditemukan');
      } else if (response.statusCode == 422) {
        try {
          final errorData = jsonDecode(responseBody);
          throw Exception('Data tidak valid: ${errorData['message'] ?? 'Validation error'}');
        } catch (e) {
          throw Exception('Data tidak valid: $responseBody');
        }
      } else {
        throw Exception('Gagal mengupdate data: ${response.statusCode}\nResponse: $responseBody');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } catch (e) {
      print('Error in updateDataPusat: $e');
      rethrow;
    }
  }

  // Hapus DataPusat
  static Future<bool> deleteDataPusat(int id) async {
    try {
      if (id <= 0) {
        throw Exception('ID tidak valid');
      }

      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      print('Delete DataPusat - Status Code: ${response.statusCode}');
      print('Delete DataPusat - Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Token expired atau tidak valid');
      } else if (response.statusCode == 404) {
        throw Exception('Data tidak ditemukan');
      } else {
        throw Exception('Gagal menghapus data: ${response.statusCode}\nResponse: ${response.body}');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } catch (e) {
      print('Error in deleteDataPusat: $e');
      rethrow;
    }
  }
}