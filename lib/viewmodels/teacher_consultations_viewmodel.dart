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
// teacher_consultations_viewmodel.dart
@override
Future<void> init(String token, String email) async {
  if (await prefs.containsItem("adminView") == false) {
    await setAdminView(0);
  } else {
    await setAdminView(int.parse(await prefs.getItem('adminView')));
  }

  isLoading = true;
  notifyListeners();
  if (!await checkConnection()) return;

  helpers.checkIfValidToken(token);
  isTeacher = await resolveUserRole(token, email);

  final fetchedReserverRooms = await api.getJoinedRooms(token);
  final fetchedAdminRooms = await api.getMyRoomsTeacher(token);

  if (fetchedReserverRooms.isEmpty && fetchedAdminRooms.isEmpty) {
    noRoomsFound = true;
    isLoading = false;
    notifyListeners();
    return;
  }

  reserverSelectedRoomId = fetchedReserverRooms.isNotEmpty
      ? fetchedReserverRooms[0].id.toString()
      : null;
  adminSelectedRoomId = fetchedAdminRooms.isNotEmpty
      ? fetchedAdminRooms[0].id.toString()
      : null;

  selectedRoomId = adminView == 1 ? adminSelectedRoomId : reserverSelectedRoomId;
  final firstRoomId = selectedRoomId ?? reserverSelectedRoomId ?? adminSelectedRoomId;

  await refreshRoomData(token, int.parse(firstRoomId!));
  isLoading = false;
  notifyListeners();
}
  Future<void> addBlock(String token) async {
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
    await setAdminView(value);
    selectedRoomId = value == 1 ? adminSelectedRoomId : reserverSelectedRoomId;

    final fetchedRooms = await fetchRooms(token);

    if (fetchedRooms.isEmpty) {
      rooms = [];
      noRoomsFound = true;
      notifyListeners();
      return;
    }

    final isValid = fetchedRooms.any((r) => r.id.toString() == selectedRoomId);

    if (!isValid) {
      final firstId = fetchedRooms[0].id.toString();
      if (value == 1) {
        adminSelectedRoomId = firstId;
      } else {
        reserverSelectedRoomId = firstId;
      }
      selectedRoomId = firstId;
    }

    await loadRoom(token);
    notifyListeners();
  }
}
