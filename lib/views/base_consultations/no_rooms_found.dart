// no_rooms_found.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Empty state shown when the user has no rooms available.
// Renders a role-aware prompt: students are directed to join a room,
// owners to create room.

import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/base_consultations_viewmodel.dart';

class NoRoomsFound extends StatelessWidget {
  final BaseConsultationsViewmodel viewModel;
  const NoRoomsFound({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 80),
              // ownerView == 0 means the current user is a student
              viewModel.ownerView == 0
                  ? GestureDetector(
                      onTap: () => nav.toJoinRoom(),
                      child: Text(
                        "Try joining room to get started.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: constants.fsTitle,
                          color: constants.primary,
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () => nav.toCreateRoom(),
                      child: Text(
                        "Try creating room to get started.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: constants.fsTitle,
                          color: constants.primary,
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
