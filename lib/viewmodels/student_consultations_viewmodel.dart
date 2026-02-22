// consultations_viewmodel.dart
import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/base_consultations_viewmodel.dart';

class StudentConsultationsViewmodel extends BaseConsultationsViewmodel {
  bool isTeacherVal = false;
  bool isLoading = false;
  Future<bool> setSelectedId(String? id) async {
    if (id == null) return false;

    final myRooms = await api.getMyRooms(
      await prefs.getItem('token'),
    ); // Fetch current user's rooms
    final isValidRoom = myRooms.any(
      (room) => room.id.toString() == id,
    ); // Check if room belongs to user
    for (var room in myRooms) {
      print("XD" + room.id.toString());
    }
    print("f" + id);
    if (isValidRoom) {
      selectedRoomId = id;
      notifyListeners();
      return true;
    } else {
      notify.showToast('Invalid room or access denied.');
      return false;
    }
  }

  Future<void> init(String token, String email) async {
    if (!await helpers.handleIsInternetConnection()) {
      notify.showToast('Please connect to internet.');
      return;
    }

    helpers.checkIfValidToken(token);
    isTeacherVal = await isTeacher(token, email);

    final myRooms = await api.getMyRooms(token);
    if (myRooms.isEmpty) {
      hasNoRooms = true;
      notifyListeners();
      return;
    }

    selectedRoomId = myRooms[0].id.toString();
    await fetchData(token, myRooms[0].id);
  }

  Future<bool> isTeacher(String token, String email) async {
    try {
      String result = await api.getRole(token, email);
      return result == "teacher";
    } catch (e) {
      notify.showToast('Error while acquiring role.');
      return false;
    }
  }
}
