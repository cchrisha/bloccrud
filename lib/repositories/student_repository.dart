import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crud/models/student_model.dart';
import 'package:crud/repositories/student_repository_impl.dart';

class StudentRepositoryImpl implements StudentRepository {
  static const String baseUrl = 'http://192.168.100.114:3000/api';

  @override
  Future<void> createStudent(Student student) async {
    final response = await http.post(
      Uri.parse('$baseUrl/createStudents'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(student.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to create student');
    }
  }

  @override
  Future<void> deleteStudent(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/deleteStudent/$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete student');
    }
  }

  @override
  Future<List<Student>> fetchStudents() async {
    final response = await http.get(
      Uri.parse('$baseUrl/getStudents'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Student.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch students');
    }
  }

  @override
  Future<void> updateStudent(String id, Student student) async {
    final response = await http.put(
      Uri.parse('$baseUrl/updateStudent/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(student.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update student');
    }
  }
}
