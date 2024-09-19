import 'package:crud/bloc/student_event.dart';
import 'package:crud/bloc/student_state.dart';
import 'package:crud/repositories/student_repository_impl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentRepository _studentRepository;

  StudentBloc(this._studentRepository) : super(StudentLoading()) {
    on<FetchStudent>((event, emit) async {
      try {
        emit(StudentLoading());
        final notes = await _studentRepository.fetchStudents();
        emit(StudentLoaded(notes));
      } catch (e) {
        emit(StudentError(e.toString()));
      }
    });

    on<CreateStudent>((event, emit) async {
      try {
        await _studentRepository.createStudent(event.student);
        add(FetchStudent());
      } catch (e) {
        emit(StudentError(e.toString()));
      }
    });

    on<DeleteStudent>((event, emit) async {
      try {
        await _studentRepository.deleteStudent(event.id);
        add(FetchStudent());
      } catch (e) {
        emit(StudentError(e.toString()));
      }
    });

    on<UpdateStudent>((event, emit) async {
      try {
        await _studentRepository.updateStudent(event.id, event.student);
        add(FetchStudent());
      } catch (e) {
        emit(StudentError(e.toString()));
      }
    });
  }
}
