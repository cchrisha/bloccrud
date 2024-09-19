import 'package:crud/bloc/student_bloc.dart';
import 'package:crud/bloc/student_event.dart';
import 'package:crud/bloc/student_state.dart';
import 'package:crud/models/student_model.dart';
import 'package:crud/repositories/student_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crup App',
      home: BlocProvider(
        create: (context) =>
            StudentBloc(StudentRepositoryImpl())..add(FetchStudent()),
        child: StudentListScreen(),
      ),
    );
  }
}

class StudentListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Students'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showNoteDialog(context, isUpdate: false),
          ),
        ],
      ),
      body: BlocBuilder<StudentBloc, StudentState>(
        builder: (context, state) {
          if (state is StudentLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StudentLoaded) {
            return ListView.builder(
              itemCount: state.students.length,
              itemBuilder: (context, index) {
                final student = state.students[index];
                return Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    leading: Icon(
                      student.enrolled ? Icons.check_circle : Icons.cancel,
                      color: student.enrolled ? Colors.green : Colors.red,
                      size: 30.0,
                    ),
                    title: Text(
                      '${student.firstName} ${student.lastName}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${student.course} - Year ${student.year}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showNoteDialog(context,
                              student: student, isUpdate: true),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => BlocProvider.of<StudentBloc>(context)
                              .add(DeleteStudent(student.id)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is StudentError) {
            return Center(child: Text(state.message));
          } else {
            return Container();
          }
        },
      ),
    );
  }

  void _showNoteDialog(BuildContext context,
      {Student? student, required bool isUpdate}) {
    final firstNameController =
        TextEditingController(text: student?.firstName ?? '');
    final lastNameController =
        TextEditingController(text: student?.lastName ?? '');
    final courseController = TextEditingController(text: student?.course ?? '');

    String selectedYear =
        student != null ? _convertIntToYear(student.year) : 'First Year';
    bool isEnrolled = student?.enrolled ?? false;

    // Access the StudentBloc from the correct context
    final studentBloc = BlocProvider.of<StudentBloc>(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(isUpdate ? 'Update Student' : 'Create Student'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: firstNameController,
                    decoration: InputDecoration(labelText: 'First Name'),
                  ),
                  TextField(
                    controller: lastNameController,
                    decoration: InputDecoration(labelText: 'Last Name'),
                  ),
                  TextField(
                    controller: courseController,
                    decoration: InputDecoration(labelText: 'Course'),
                  ),
                  DropdownButtonFormField<String>(
                    value: null,
                    decoration: InputDecoration(labelText: 'Year'),
                    items: [
                      'First Year',
                      'Second Year',
                      'Third Year',
                      'Fourth Year',
                      'Fifth Year'
                    ]
                        .map((year) => DropdownMenuItem(
                              value: year,
                              child: Text(year),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value!;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Enrolled',
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Colors
                                .black87), // Customize the text style if needed
                      ),
                      Switch(
                        value: isEnrolled,
                        onChanged: (value) {
                          setState(() {
                            isEnrolled = value;
                          });
                        },
                        activeColor: Colors.blue, // Color when switch is on
                        inactiveThumbColor: Colors
                            .grey, // Color of the thumb when switch is off
                        inactiveTrackColor: Colors
                            .grey[300], // Color of the track when switch is off
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                        color: Colors.red), // Set color for Cancel button
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (firstNameController.text.isEmpty ||
                        lastNameController.text.isEmpty ||
                        courseController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill all the fields')),
                      );
                      return;
                    }

                    final newStudent = Student(
                      id: isUpdate ? student!.id : '',
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      course: courseController.text,
                      year: _convertYearToInt(selectedYear),
                      enrolled: isEnrolled,
                    );
                    if (isUpdate) {
                      studentBloc.add(UpdateStudent(newStudent.id, newStudent));
                    } else {
                      studentBloc.add(CreateStudent(newStudent));
                    }
                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    isUpdate ? 'Update' : 'Create',
                    style: const TextStyle(
                        color:
                            Colors.blue), // Set color for Update/Create button
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

//Convert int year string
  String _convertIntToYear(int year) {
    switch (year) {
      case 1:
        return 'First Year';
      case 2:
        return 'Second Year';
      case 3:
        return 'Third Year';
      case 4:
        return 'Fourth Year';
      case 5:
        return 'Fifth Year';
      default:
        return 'First Year';
    }
  }

//Convert year string to int
  int _convertYearToInt(String year) {
    switch (year) {
      case 'First Year':
        return 1;
      case 'Second Year':
        return 2;
      case 'Third Year':
        return 3;
      case 'Fourth Year':
        return 4;
      case 'Fifth Year':
        return 5;
      default:
        return 1;
    }
  }
  // void _showNoteDialog(BuildContext context,
  //     {Student? student, required bool isUpdate}) {
  //   final firstNameController =
  //       TextEditingController(text: student?.firstName ?? '');
  //   final lastNameController =
  //       TextEditingController(text: student?.lastName ?? '');
  //   final courseController = TextEditingController(text: student?.course ?? '');
  //   final yearController = TextEditingController(text: student?.year ?? '');
  //   final enrolledController =
  //       TextEditingController(text: student?.enrolled ?? '');

  //   showDialog(
  //     context: context,
  //     builder: (dialogContext) {
  //       return AlertDialog(
  //         title: Text(isUpdate ? 'Update Student' : 'Create Student'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextField(
  //               controller: firstNameController,
  //               decoration: InputDecoration(labelText: 'First Name'),
  //             ),
  //             TextField(
  //               controller: lastNameController,
  //               decoration: InputDecoration(labelText: 'Last Name'),
  //             ),
  //             TextField(
  //               controller: courseController,
  //               decoration: InputDecoration(labelText: 'Course'),
  //             ),
  //             TextField(
  //               controller: yearController,
  //               decoration: InputDecoration(labelText: 'Year'),
  //             ),
  //             TextField(
  //               controller: enrolledController,
  //               decoration: InputDecoration(labelText: 'Enrolled'),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(dialogContext),
  //             child: Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               // Access BlocProvider with correct type and context
  //               final studentBloc = BlocProvider.of<StudentBloc>(context);
  //               final newStudent = Student(
  //                 id: isUpdate ? student!.id : '',
  //                 firstName: firstNameController.text,
  //                 lastName: lastNameController.text,
  //                 course: courseController.text,
  //                 year: yearController.text,
  //                 enrolled: enrolledController.text,
  //               );
  //               if (isUpdate) {
  //                 studentBloc.add(UpdateStudent(newStudent.id, newStudent));
  //               } else {
  //                 studentBloc.add(CreateStudent(newStudent));
  //               }
  //               Navigator.pop(dialogContext);
  //             },
  //             child: Text(isUpdate ? 'Update' : 'Create'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
