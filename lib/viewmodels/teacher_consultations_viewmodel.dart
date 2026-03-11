// teacher_consultations_viewmodel.dart
import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/base_consultations_viewmodel.dart';

class TeacherConsultationsViewmodel extends BaseConsultationsViewmodel {
  bool isTeacherVal = false;
  bool isLoading = false;
  Future<void> init(String token, String email) async {
    if (!await helpers.handleIsInternetConnection()) {
      notify.showToast('Please connect to internet.');
      return;
    }

    helpers.checkIfValidToken(token);
    isTeacherVal = await isTeacher(token, email);
    final myRooms = await api.getMyRoomsTeacher(token);
    if (myRooms.isEmpty) {
      hasNoRooms = true;
      notifyListeners();
      return;
    }

    selectedRoomId = myRooms[0].id.toString();
    await fetchData(token, myRooms[0].id, true);
  }

  Future<void> onRoomChanged(String newRoomId) async {
    isLoading = true;
    notifyListeners();
    await loadRoom(await prefs.getItem("token"), int.parse(newRoomId), true);

    isLoading = false;
    notifyListeners();
  }

  Future<bool> setSelectedId(String? id) async {
    if (id == null) return false;

    final myRooms = await api.getMyRoomsTeacher(await prefs.getItem('token'));
    final isValidRoom = myRooms.any((room) => room.id.toString() == id);

    if (isValidRoom) {
      selectedRoomId = id;
      notifyListeners();
      return true;
    } else {
      notify.showToast('Invalid room or access denied.');
      return false;
    }
  }

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();
    if (selectedRoomId == null) {
      await init(await prefs.getItem("token"), await prefs.getItem("email"));
      isLoading = false;
      notifyListeners();
      return;
    }

    await loadRoom(
      await prefs.getItem("token"),
      int.parse(selectedRoomId!),
      true,
    );
    isLoading = false;
    notifyListeners();
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

  Future<void> deleteRoom(String token) async {
    try {
      bool b = await api.deleteRoom(token, int.parse(safeSelectedRoomId!));
      if (b) {
        notify.showToast('Room was successfully deleted.');
      }
    } catch (e) {
      notify.showToast('Error while deleting room.');
    }
  }
}
