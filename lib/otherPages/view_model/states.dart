
import '../../models/Studentmodel.dart';

sealed class AbsentState {}

class AbsentInitial extends AbsentState {}

class AbsentLoading extends AbsentState {}

class AbsenceFetched extends AbsentState {}

class AttendanceStarted extends AbsentState {}

class StudentAddedToPresent extends AbsentState {
  final Studentmodel student;

  StudentAddedToPresent(this.student);
}

class ScanSuccess extends AbsentState {
  final Studentmodel student;

  ScanSuccess(this.student);
}


class SearchResultsUpdated extends AbsentState {
  final List<Studentmodel> filteredStudents;

  SearchResultsUpdated(this.filteredStudents);
}

class AbsentError extends AbsentState {
  final String error;

  AbsentError(this.error);
}
