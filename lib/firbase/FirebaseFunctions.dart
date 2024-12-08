import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/Magmo3amodel.dart';
import '../models/Studentmodel.dart';
import '../models/absancemodel.dart';

class Firebasefunctions {
  // =======================================================================
  // General Utility Functions
  // =======================================================================

  /// Gets a reference to the collection for a specific day (e.g., "Sunday", "Monday").
  static CollectionReference<Magmo3amodel> getDayCollection(String day) {
    return FirebaseFirestore.instance
        .collection(day) // Collection for each day
        .withConverter<Magmo3amodel>(
      fromFirestore: (snapshot, _) => Magmo3amodel.fromJson(snapshot.data()!),
      toFirestore: (value, _) => value.toJson(),
    );
  }

  /// Gets a reference to the collection for a specific grade (e.g., "1 secondary", "2 secondary").
  static CollectionReference<Studentmodel> getSecondaryCollection(String grade) {
    return FirebaseFirestore.instance
        .collection(grade)
        .withConverter<Studentmodel>(
      fromFirestore: (snapshot, _) => Studentmodel.fromJson(snapshot.data()!),
      toFirestore: (value, _) => value.toJson(),
    );
  }

  // =======================================================================
  // Stream Functions for Listening to Firestore Changes
  // =======================================================================

  /// Streams all documents from a specific day's collection.
  static Stream<List<Magmo3amodel>> getAllDocsFromDay(String day) {
    CollectionReference<Magmo3amodel> dayCollection = getDayCollection(day);
    return dayCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  /// Streams students by first day ID.
  static Stream<QuerySnapshot<Studentmodel>> getStudentsByFirstDayId(String grade, String firstdayid) {
    return getSecondaryCollection(grade)
        .where("firstdayid", isEqualTo: firstdayid)
        .snapshots();
  }

  /// Streams students by second day ID.
  static Stream<QuerySnapshot<Studentmodel>> getStudentsBySecondDayId(String grade, String seconddayid) {
    return getSecondaryCollection(grade)
        .where("seconddayid", isEqualTo: seconddayid)
        .snapshots();
  }

  /// Streams students by third day ID.
  static Stream<QuerySnapshot<Studentmodel>> getStudentsByThirdDayId(String grade, String thirddayid) {
    return getSecondaryCollection(grade)
        .where("thirddayid", isEqualTo: thirddayid)
        .snapshots();
  }

  /// Streams students by fourth day ID.
  static Stream<QuerySnapshot<Studentmodel>> getStudentsByForthDayId(String grade, String forthdayid) {
    return getSecondaryCollection(grade)
        .where("forthdayid", isEqualTo: forthdayid)
        .snapshots();
  }

  // =======================================================================
  // Absence Management Functions
  // =======================================================================

  /// Adds an absence to the "absences" subcollection.
  static Future<void> addAbsenceToSubcollection(String day, String magmo3aId, AbsenceModel absence) async {
    try {
      CollectionReference<Magmo3amodel> dayCollection = getDayCollection(day);
      DocumentReference<Magmo3amodel> magmo3aDocRef = dayCollection.doc(magmo3aId);
      DocumentSnapshot<Magmo3amodel> magmo3aSnapshot = await magmo3aDocRef.get();

      if (!magmo3aSnapshot.exists) {
        throw Exception("Group (Magmo3a) not found.");
      }

      CollectionReference<AbsenceModel> absencesSubcollectionRef = magmo3aDocRef.collection('absences').withConverter<AbsenceModel>(
        fromFirestore: (snapshot, _) => AbsenceModel.fromJson(snapshot.data()!),
        toFirestore: (value, _) => value.toJson(),
      );

      await absencesSubcollectionRef.doc(absence.date).set(absence);
    } catch (e) {
      print("Error adding absence: $e");
    }
  }

  /// Deletes an absence from the "absences" subcollection.
  static Future<void> deleteAbsenceFromSubcollection(String day, String magmo3aId, String absenceDate) async {
    try {
      CollectionReference<Magmo3amodel> dayCollection = getDayCollection(day);
      DocumentReference<Magmo3amodel> magmo3aDocRef = dayCollection.doc(magmo3aId);
      DocumentSnapshot<Magmo3amodel> magmo3aSnapshot = await magmo3aDocRef.get();

      if (!magmo3aSnapshot.exists) {
        throw Exception("Group (Magmo3a) not found.");
      }

      CollectionReference<AbsenceModel> absencesSubcollectionRef = magmo3aDocRef.collection('absences').withConverter<AbsenceModel>(
        fromFirestore: (snapshot, _) => AbsenceModel.fromJson(snapshot.data()!),
        toFirestore: (value, _) => value.toJson(),
      );

      await absencesSubcollectionRef.doc(absenceDate).delete();
    } catch (e) {
      print("Error deleting absence: $e");
    }
  }

  /// Updates an absence record by its date in the subcollection.
  static Future<void> updateAbsenceByDateInSubcollection(String day, String magmo3aId, String absenceDate, AbsenceModel updatedAbsence) async {
    try {
      CollectionReference<Magmo3amodel> dayCollection = getDayCollection(day);
      DocumentReference<Magmo3amodel> magmo3aDocRef = dayCollection.doc(magmo3aId);
      DocumentSnapshot<Magmo3amodel> magmo3aSnapshot = await magmo3aDocRef.get();

      if (!magmo3aSnapshot.exists) {
        throw Exception("Group (Magmo3a) not found.");
      }

      CollectionReference<AbsenceModel> absencesSubcollectionRef = magmo3aDocRef.collection('absences').withConverter<AbsenceModel>(
        fromFirestore: (snapshot, _) => AbsenceModel.fromJson(snapshot.data()!),
        toFirestore: (value, _) => value.toJson(),
      );

      DocumentReference<AbsenceModel> absenceDocRef = absencesSubcollectionRef.doc(absenceDate);
      await absenceDocRef.set(updatedAbsence);
    } catch (e) {
      print("Error updating absence: $e");
    }
  }

  /// Fetches an absence record by its date.
  static Future<AbsenceModel?> getAbsenceByDate(String day, String groupId, String date) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection(day)
          .doc(groupId)
          .collection('absences')
          .doc(date)
          .get();

      if (doc.exists) {
        return AbsenceModel.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching absence record: $e");
      return null;
    }
  }

  // =======================================================================
  // Student Management Functions
  // =======================================================================

  static Future<void> updateStudentInCollection(
      String grade, String studentId, Studentmodel updatedStudentModel) async {
    CollectionReference<Studentmodel> collection = getSecondaryCollection(grade);
    await collection.doc(studentId).update(updatedStudentModel.toJson());
  }


  /// Fetches a student by their ID from a specific grade.
  static Future<Studentmodel?> getStudentById(String grade, String studentId) async {
    try {
      CollectionReference<Studentmodel> studentsCollection = getSecondaryCollection(grade);
      DocumentSnapshot<Studentmodel> studentSnapshot = await studentsCollection.doc(studentId).get();

      if (studentSnapshot.exists) {
        return studentSnapshot.data();
      } else {
        print("Student not found.");
        return null;
      }
    } catch (e) {
      print("Error fetching student: $e");
      return null;
    }
  }

  /// Updates a student within a specific absence record.
  static Future<void> updateStudentInAbsence(String day, String magmo3aId, String absenceDate, String studentId, Studentmodel updatedStudent) async {
    try {
      CollectionReference<Magmo3amodel> dayCollection = getDayCollection(day);
      DocumentReference<Magmo3amodel> magmo3aDocRef = dayCollection.doc(magmo3aId);
      DocumentSnapshot<Magmo3amodel> magmo3aSnapshot = await magmo3aDocRef.get();

      if (!magmo3aSnapshot.exists) {
        throw Exception("Group (Magmo3a) not found.");
      }

      CollectionReference<AbsenceModel> absencesSubcollectionRef = magmo3aDocRef.collection('absences').withConverter<AbsenceModel>(
        fromFirestore: (snapshot, _) => AbsenceModel.fromJson(snapshot.data()!),
        toFirestore: (value, _) => value.toJson(),
      );

      DocumentReference<AbsenceModel> absenceDocRef = absencesSubcollectionRef.doc(absenceDate);
      AbsenceModel? absenceData = await absenceDocRef.get().then((snapshot) => snapshot.data());

      if (absenceData != null) {
        List<Studentmodel> students = absenceData.absentStudents;

        for (int i = 0; i < students.length; i++) {
          if (students[i].id == studentId) {
            students[i] = updatedStudent;
            break;
          }
        }

        await absenceDocRef.set(absenceData);
      } else {
        print("Absence document not found.");
      }
    } catch (e) {
      print("Error updating student in absence: $e");
    }
  }
}
