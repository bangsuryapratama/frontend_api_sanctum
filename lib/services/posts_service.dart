import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_api/models/posts_model.dart';

class PostsService {
  static const String postsUrl = 'http://127.0.0.1:8000/api/posts';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  } 

   static Future<PostModel> listPost() async {
  final token = await getToken();
  final response = await http.get(
    Uri.parse(postsUrl),
    headers: {HttpHeaders.authorizationHeader : 'Bearer $token'},
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return PostModel.fromJson(data);
  } else {
    throw Exception('Gagal brow');
  }
}


}
