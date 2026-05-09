// my_reservations_page.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Displays the list of the current user's reservations

import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/my_reservations_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

// Provides the ViewModel and switches between a loading spinner and the body.
class MyReservationsPage extends StatelessWidget {
  const MyReservationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyReservationsViewModel()..initialize(),
      child: Consumer<MyReservationsViewModel>(
        builder: (context, viewModel, _) => Scaffold(
          appBar: AppBarMenu(),
          drawer: SliderMenu(),
          backgroundColor: constants.background,
          body: SafeArea(
            child: viewModel.isLoading
                ? Center(
                    child: SpinKitPouringHourGlass(
                      color: constants.primary,
                      size: constants.fsHeadline,
                    ),
                  )
                : _ReservationsBody(viewModel: viewModel),
          ),
        ),
      ),
    );
  }
}

// Renders the page header and either the reservation list or the empty state.
class _ReservationsBody extends StatelessWidget {
  final MyReservationsViewModel viewModel;

  const _ReservationsBody({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "My Reservations",
            style: TextStyle(
              fontSize: constants.fsHeadline,
              fontWeight: constants.fwSemiBold,
              color: constants.darkGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Your upcoming and past consultation slots",
            style: TextStyle(
              fontSize: constants.fsLabel,
              color: constants.darkGrey150,
            ),
          ),
          const SizedBox(height: 20),
          viewModel.reservations.isEmpty
              ? const _EmptyState()
              : Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      overscroll: false,
                    ),
                    child: ListView.separated(
                      itemCount: viewModel.reservations.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _ReservationCard(
                          index: index,
                          viewModel: viewModel,
                        );
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

// Displays a single reservation with date, time, duration, meeting type
// toggle, optional note, and a cancel button.

class _ReservationCard extends StatefulWidget {
  final int index;
  final MyReservationsViewModel viewModel;
  const _ReservationCard({required this.index, required this.viewModel});

  @override
  State<_ReservationCard> createState() => _ReservationCardState();
}

class _ReservationCardState extends State<_ReservationCard> {
  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final s = viewModel.slotEssentials(widget.index);

    final int slotId = s['slotId'];
    final String date = s['date'];
    final String roomName = s['roomName'];
    final String startTime = s['startTime'];
    final int duration = s['duration'];
    final String note = s['note'];
    final bool isOnline = s['isOnline'];
    final bool isReleasing = s['isReleasing'];
    final bool isChanging = s['isChanging'];
    return Container(
      decoration: constants.squircleShadow(
        hasBorder: true,
        color: constants.background,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              textAlign: TextAlign.center,
              roomName,
              style: TextStyle(
                fontWeight: constants.fwSemiBold,
                fontSize: constants.fsTitle,
                color: constants.darkGrey,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Row: date on the left, meeting type toggle on the right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  svgs.icon(
                    "calendar",
                    constants.primary,
                    width: constants.fsBody,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    date.replaceAll("-", "."),
                    style: TextStyle(
                      fontWeight: constants.fwRegular,
                      fontSize: constants.fsBody,
                      color: constants.darkGrey,
                    ),
                  ),
                ],
              ),
              // Tapping opens the consultation-type bottom sheet;
              GestureDetector(
                onTap: isChanging || isReleasing
                    ? null
                    : () => viewModel.openTypeSheet(context, slotId, isOnline),
                child: isChanging
                    ? SpinKitPouringHourGlass(
                        color: constants.primary,
                        size: constants.fsTitle,
                      )
                    : _MeetingTypeSelector(isOnline: isOnline),
              ),
            ],
          ),

          const SizedBox(height: 16),
          // Row: start time + duration on the left, cancel button on the right
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  svgs.icon(
                    "clock",
                    constants.darkGrey,
                    width: constants.fsLabel,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    startTime,
                    style: TextStyle(
                      fontSize: constants.fsLabel,
                      color: constants.darkGrey,
                    ),
                  ),
                  Text(
                    "  –  ",
                    style: TextStyle(
                      fontSize: constants.fsLabel,
                      color: constants.darkGrey150,
                    ),
                  ),
                  svgs.icon(
                    "hourglass",
                    constants.darkGrey,
                    width: constants.fsLabel,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "$duration min",
                    style: TextStyle(
                      fontSize: constants.fsLabel,
                      color: constants.darkGrey,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Cancel button — shows a spinner while the release is pending.
              GestureDetector(
                onTap: isReleasing || isChanging
                    ? null
                    : () => viewModel.releaseSlot(slotId),
                child: isReleasing
                    ? SpinKitPouringHourGlass(
                        color: constants.red,
                        size: constants.fsBody,
                      )
                    : svgs.icon(
                        "cross",
                        constants.red,
                        width: constants.fsHeadline,
                      ),
              ),
            ],
          ),
          note.isEmpty ? SizedBox.shrink() : const SizedBox(height: 16),
          // hidden entirely when note is empty.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              note.isEmpty
                  ? SizedBox.shrink()
                  : svgs.icon(
                      "pencil",
                      constants.darkGrey,
                      width: constants.fsLabel,
                    ),
              note.isEmpty ? SizedBox.shrink() : SizedBox(width: 12),
              note.isEmpty
                  ? SizedBox.shrink()
                  : Expanded(
                      child: Text(
                        note,
                        style: TextStyle(
                          fontSize: constants.fsLabel,
                          color: constants.darkGrey,
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

// Shows a screen icon for online or a location pin for in-person.
class _MeetingTypeSelector extends StatelessWidget {
  final bool isOnline;

  const _MeetingTypeSelector({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return isOnline
        ? svgs.icon('screen', constants.primary, width: constants.fsHeadline)
        : svgs.icon('location', constants.primary, width: constants.fsHeadline);
  }
}

// Shown when the user has no reservations.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            svgs.icon("calendar", constants.darkGrey, width: 56),
            const SizedBox(height: 16),
            Text(
              "No reservations yet",
              style: TextStyle(
                fontSize: constants.fsTitle,
                fontWeight: constants.fwSemiBold,
                color: constants.darkGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Join a room to book your first slot",
              style: TextStyle(
                fontSize: constants.fsLabel,
                color: constants.darkGrey150,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
