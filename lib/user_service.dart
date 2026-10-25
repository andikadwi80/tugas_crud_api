import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'user_model.dart';

class UserService {
  static const String baseUrl = "https://reqres.in/api/users";

  // 1. GET: Ambil daftar user
  Future<List<UserModel>> getUsers() async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl?page=1"))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        return data.map((item) => UserModel.fromJson(item)).toList();
      } else {
        throw Exception("Gagal mengambil data (Status Code: ${response.statusCode})");
      }
    } on SocketException {
      throw Exception("Tidak ada koneksi internet");
    } catch (e) {
      throw Exception("Terjadi kesalahan: $e");
    }
  }

  // 2. POST: Buat user baru
  Future<bool> createUser(String name, String job) async {
    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"name": name, "job": job}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception("Gagal membuat user (Status Code: ${response.statusCode})");
      }
    } on SocketException {
      throw Exception("Tidak ada koneksi internet");
    } catch (e) {
      throw Exception("Terjadi kesalahan: $e");
    }
  }

  // 3. PUT: Perbarui data user
  Future<bool> updateUser(int id, String name, String job) async {
    try {
      final response = await http
          .put(
            Uri.parse("$baseUrl/$id"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"name": name, "job": job}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception("Gagal memperbarui user (Status Code: ${response.statusCode})");
      }
    } on SocketException {
      throw Exception("Tidak ada koneksi internet");
    } catch (e) {
      throw Exception("Terjadi kesalahan: $e");
    }
  }

  // 4. DELETE: Hapus user
  Future<bool> deleteUser(int id) async {
    try {
      final response = await http
          .delete(Uri.parse("$baseUrl/$id"))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 204) {
        return true;
      } else {
        throw Exception("Gagal menghapus user (Status Code: ${response.statusCode})");
      }
    } on SocketException {
      throw Exception("Tidak ada koneksi internet");
    } catch (e) {
      throw Exception("Terjadi kesalahan: $e");
    }
  }
}