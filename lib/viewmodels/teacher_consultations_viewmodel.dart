// teacher_consultations_viewmodel.dart
import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/base_consultations_viewmodel.dart';

class TeacherConsultationsViewmodel extends BaseConsultationsViewmodel {
  //0=reserver, 1=admin

  @override
  Future<List<RoomModel>> fetchRooms(String token) =>
      adminView == 0 ? api.getJoinedRooms(token) : api.getMyRoomsTeacher(token);

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

 void toggleView(String token, int value) async {
    if (value == 0) {
      selectedRoomId = reserverSelectedRoomId;
    } else {
      selectedRoomId = adminSelectedRoomId;
    }

    await setAdminView(value);
    await loadRoom(token);

    if (rooms != null && rooms!.isNotEmpty) {
      final isValid = rooms!.any((r) => r.id.toString() == selectedRoomId);
      if (!isValid) {
        selectedRoomId = rooms![0].id.toString();
        if (value == 0) {
          reserverSelectedRoomId = selectedRoomId;
        } else {
          adminSelectedRoomId = selectedRoomId;
        }
      }
    }

    notifyListeners();
  }
}
