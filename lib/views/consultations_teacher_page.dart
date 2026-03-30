import 'package:consultation_app/viewmodels/teacher_consultations_viewmodel.dart';
import 'package:consultation_app/views/consultations_base_page.dart';
import 'package:consultation_app/views/custom_widgets/animated_toggle_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:consultation_app/setup.dart';

class ConsultationsTeacherPage extends StatefulWidget {
  final String token;
  final String email;
  const ConsultationsTeacherPage({
    super.key,
    required this.token,
    required this.email,
  });

  @override
  State<ConsultationsTeacherPage> createState() =>
      _ConsultationsTeacherPageState();
}

class _ConsultationsTeacherPageState extends State<ConsultationsTeacherPage> {
  late final TeacherConsultationsViewmodel _viewModel;
  @override
  void initState() {
    super.initState();
    _viewModel = TeacherConsultationsViewmodel();
    _viewModel.init(widget.token, widget.email);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<TeacherConsultationsViewmodel>(
        builder: (context, viewModel, child) {
          final isAdmin = _viewModel.adminView == 1;
          return BaseConsultationsPage(
            token: widget.token,
            email: widget.email,
            viewModel: viewModel,
            toggle: AnimatedToggle(
              isAdmin: isAdmin,
              values: const ['Admin', 'Reserver'],
              onToggleCallback: (value) =>
                  viewModel.toggleView(widget.token, value),
              width: 200,
              height: 50,
              buttonColor: constants.primary,
              backgroundColor: constants.grey,
              textColor: constants.background,
            ),
            addButton: isAdmin
                ? GestureDetector(
                    onTap: () => nav.toCreateBlock(
                      token: widget.token,
                      roomId: viewModel.safeSelectedRoomId!,
                      onSuccess: () => viewModel.loadRoom(widget.token),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: constants.squircleShadow(
                        color: constants.grey,
                      ),
                      child: Icon(
                        Icons.add,
                        size: 25,
                        color: constants.darkGrey,
                      ),
                    ),
                  )
                : null,
            deleteButton: isAdmin
                ? GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Delete ',
                                  style: TextStyle(
                                    fontWeight: constants.fwRegular,
                                    fontSize: constants.fsBody,
                                  ),
                                ),
                                TextSpan(
                                  text: '${viewModel.getRoomNameById()}?',
                                  style: TextStyle(
                                    fontWeight: constants.fwSemiBold,
                                    fontSize: constants.fsBody,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => nav.pop(),
                              child: Text(
                                "Cancel",
                                style: TextStyle(color: constants.primary),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await viewModel.deleteRoom(widget.token);
                                await viewModel.loadRoom(widget.token);
                                nav.pop();
                              },
                              child: Text(
                                "Delete",
                                style: TextStyle(color: constants.primary),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: constants.squircleShadow(
                        color: constants.grey,
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 25,
                        color: constants.darkGrey,
                      ),
                    ),
                  )
                : null,
            editBlockButton: isAdmin
                ? (blockId) => GestureDetector(
                    onTap: () => nav.toEditBlock(
                      token: widget.token,
                      roomId: viewModel.safeSelectedRoomId!,
                      blockId: blockId.toString(),
                      onSuccess: () => viewModel.loadRoom(widget.token),
                    ),
                    child: SvgPicture.asset(
                      'assets/resources/edit.svg',
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        constants.darkGrey,
                        BlendMode.srcIn,
                      ),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }
}
