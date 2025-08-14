import 'dart:convert';
// import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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

//get single post by id

static Future<DataPost> showPost(int id) async {
  final token = await getToken();
  final response = await http.get(
    Uri.parse('$postsUrl/$id'),
    headers: {HttpHeaders.authorizationHeader:'Bearer $token'},
  );

  if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return DataPost.fromJson(data['data']);
  } else {
    throw Exception('Gagal');
  }
}

//create new posts

static Future<bool> createPost(
  String  title,
  String  content,
  int status, [
    Uint8List? imageBytes,
    String? imageName,
  ]) async {
    final token = await getToken();
    final uri = Uri.parse(postsUrl);
    final request = http.MultipartRequest('POST', uri);

    request.fields['title'] = title;
    request.fields['content'] = content;
    request.fields['status'] = status.toString();

    if (imageBytes != null && imageName != null) {
        request.files.add(
           http.MultipartFile.fromBytes(
              'foto',
              imageBytes,
              filename: imageName,
              contentType: MediaType('image', 'jpeg'),
           ),
        );
      }

      request.headers['Authorization'] = 'Bearer $token';

      final response = await request.send();
      return response.statusCode == 201;
  }

  //Update existing post
  static Future<bool> updatePost(
    int id,
    String title,
    String content,
    int status, [
      Uint8List? imageBytes,
      String? imageName,
    ]) async {
       final token = await getToken();
       var request = http.MultipartRequest(
        'POST',
        Uri.parse('$postsUrl/$id?_method=PUT'),
       );

       request.fields['title'] = title;
       request.fields['content'] = content;
       request.fields['status'] = status.toString();

        if (imageBytes != null && imageName != null) {
        request.files.add(
           http.MultipartFile.fromBytes(
              'foto',
              imageBytes,
              filename: imageName,
              contentType: MediaType('image', 'jpeg'),
           ),
        );
      }

      request.headers['Authorization'] = 'Bearer $token';

      final response = await request.send();
      return response.statusCode == 200;

    }

    //delete 
    static Future<bool> deletePost(int id) async {
      final token = await getToken();
      final response = await http.delete(
        Uri.parse('$postsUrl/$id'),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'}
      );

      return response.statusCode == 200;
    }


}
