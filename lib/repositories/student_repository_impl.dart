import 'package:crud/models/student_model.dart';

abstract class StudentRepository {
  Future<List<Student>> fetchStudents();
  Future<void> createStudent(Student student);
  Future<void> deleteStudent(String id);
  Future<void> updateStudent(String id, Student student);
}
