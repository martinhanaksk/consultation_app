// teacher_consultations_viewmodel.dart
import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/base_consultations_viewmodel.dart';

class TeacherConsultationsViewmodel extends BaseConsultationsViewmodel {

  Future<void> init(String token) async {
    if (!await helpers.handleIsInternetConnection()) {
      notify.showToast('Please connect to internet.');
      return;
    }

    helpers.checkIfValidToken(token);

    final myRooms = await api.getMyRooms(token);
    if (myRooms.isEmpty) {
      hasNoRooms = true;
      notifyListeners();
      return;
    }

    selectedRoomId = myRooms[0].id.toString();
    await fetchData(token, myRooms[0].id);
  }
}