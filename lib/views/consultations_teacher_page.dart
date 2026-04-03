import 'package:consultation_app/viewmodels/teacher_consultations_viewmodel.dart';
import 'package:consultation_app/views/consultations_base_page.dart';
import 'package:consultation_app/views/custom_widgets/animated_toggle_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
          final isOwner = viewModel.ownerView == 1;
          return BaseConsultationsPage(
            token: widget.token,
            email: widget.email,
            viewModel: viewModel,
            toggle: AnimatedToggle(
              isOwner: isOwner,
              values: const ['Owner', 'Visitor'],
              onToggleCallback: (value) =>
                  viewModel.toggleView(widget.token, value),
              width: 200,
              height: 50,
              buttonColor: constants.primary,
              backgroundColor: constants.grey,
              textColor: constants.background,
            ),
            addButton: isOwner
                ? _AddBlockButton(token: widget.token, viewModel: viewModel)
                : null,
            deleteButton: isOwner
                ? _DeleteRoomButton(token: widget.token, viewModel: viewModel)
                : null,
            editBlockButton: isOwner
                ? (blockId) => _EditBlockButton(
                    token: widget.token,
                    blockId: blockId,
                    viewModel: viewModel,
                  )
                : null,
            addSlotBefore: isOwner
                ? (blockId, isEmpty) => _AddSlotOnOutskirts(
                    token: widget.token,
                    viewModel: viewModel,
                    blockId: blockId,
                    isBefore: true,
                    isEmpty: isEmpty,
                  )
                : null,
            addSlotAfter: isOwner
                ? (blockId, isEmpty) => _AddSlotOnOutskirts(
                    token: widget.token,
                    viewModel: viewModel,
                    blockId: blockId,
                    isBefore: false,
                    isEmpty: isEmpty,
                  )
                : null,
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _AddSlotOnOutskirts extends StatelessWidget {
  final String token;
  final TeacherConsultationsViewmodel viewModel;
  final int blockId;
  final bool isBefore;
  final bool isEmpty;

  const _AddSlotOnOutskirts({
    required this.token,
    required this.viewModel,
    required this.blockId,
    required this.isBefore,
    required this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return isEmpty
        ? const SizedBox.shrink()
        : GestureDetector(
            onTap: () async {
              if (isBefore) {
                viewModel.setIsLoading(true);
                await viewModel.addSlotBeforeBlock(token, blockId);
                await viewModel.loadRoom(token);
                viewModel.setIsLoading(false);
              } else {
                viewModel.setIsLoading(true);
                await viewModel.addSlotAfterBlock(token, blockId);
                await viewModel.loadRoom(token);
                viewModel.setIsLoading(false);
              }
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Icon(
                Icons.add,

                color: constants.darkGrey,
                size: constants.fsHeadline,
              ),
            ),
          );
  }
}

class _AddBlockButton extends StatelessWidget {
  final String token;
  final TeacherConsultationsViewmodel viewModel;

  const _AddBlockButton({required this.token, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return (viewModel.noRoomsFound || viewModel.selectedRoomId == null)
        ? const SizedBox.shrink()
        : GestureDetector(
            onTap: () => nav.toCreateBlock(
              token: token,
              roomId: viewModel.safeSelectedRoomId!,
              onSuccess: () => viewModel.loadRoom(token),
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: constants.squircleShadow(color: constants.grey),
              child: Icon(Icons.add, size: 25, color: constants.darkGrey),
            ),
          );
  }
}

// ---------------------------------------------------------------------------

class _DeleteRoomButton extends StatelessWidget {
  final String token;
  final TeacherConsultationsViewmodel viewModel;

  const _DeleteRoomButton({required this.token, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return (viewModel.noRoomsFound || viewModel.selectedRoomId == null)
        ? const SizedBox.shrink()
        : GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (_) =>
                  _DeleteRoomDialog(token: token, viewModel: viewModel),
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: constants.squircleShadow(color: constants.grey),
              child: Icon(
                Icons.delete_outline_rounded,
                size: 25,
                color: constants.darkGrey,
              ),
            ),
          );
  }
}

class _DeleteRoomDialog extends StatelessWidget {
  final String token;
  final TeacherConsultationsViewmodel viewModel;

  const _DeleteRoomDialog({required this.token, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Delete ',
              style: TextStyle(
                color: constants.darkGrey,
                fontWeight: constants.fwRegular,
                fontSize: constants.fsBody,
              ),
            ),
            TextSpan(
              text: '${viewModel.getRoomNameById()}?',
              style: TextStyle(
                color: constants.darkGrey,
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
          child: Text("Cancel", style: TextStyle(color: constants.primary)),
        ),
        ElevatedButton(
          onPressed: () async {
            await viewModel.deleteRoom(token);
            
          },
          child: Text("Delete", style: TextStyle(color: constants.primary)),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _EditBlockButton extends StatelessWidget {
  final String token;
  final int blockId;
  final TeacherConsultationsViewmodel viewModel;

  const _EditBlockButton({
    required this.token,
    required this.blockId,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => nav.toEditBlock(
        token: token,
        roomId: viewModel.safeSelectedRoomId!,
        blockId: blockId.toString(),
        onSuccess: () => viewModel.loadRoom(token),
      ),
      child: SvgPicture.asset(
        'assets/resources/edit.svg',
        height: 24,
        colorFilter: ColorFilter.mode(constants.darkGrey, BlendMode.srcIn),
      ),
    );
  }
}
