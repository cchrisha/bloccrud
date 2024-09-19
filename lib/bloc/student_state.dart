import 'package:crud/models/student_model.dart';
import 'package:equatable/equatable.dart';

abstract class StudentState extends Equatable {
  const StudentState();

  @override
  List<Object> get props => [];
}

class StudentLoading extends StudentState {}

class StudentLoaded extends StudentState {
  final List<Student> students;

  const StudentLoaded(this.students);

  @override
  List<Object> get props => [students];
}

class StudentError extends StudentState {
  final String message;

  const StudentError(this.message);

  @override
  List<Object> get props => [message];
}
