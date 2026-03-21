// teacher_consultations_viewmodel.dart
import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/base_consultations_viewmodel.dart';

class TeacherConsultationsViewmodel extends BaseConsultationsViewmodel {
  //0=student, 1=teacher
  
  @override
  Future<List<RoomModel>> fetchRooms(String token) => teacherView == 0
      ? api.getJoinedRooms(token)
      : api.getMyRoomsTeacher(token);
  
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

  void toggleView(String token, int value)async {
    await setTeacherView(value);
    await loadRoom(token);
    notifyListeners();
  }
}
