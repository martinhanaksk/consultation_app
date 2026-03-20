// teacher_consultations_viewmodel.dart
import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/base_consultations_viewmodel.dart';

class TeacherConsultationsViewmodel extends BaseConsultationsViewmodel {
  @override
  Future<List<RoomModel>> fetchRooms(String token) => teacherView?api.getMyRoomsTeacher(token): api.getJoinedRooms(token);
    
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
