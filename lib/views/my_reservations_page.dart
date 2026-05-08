// my_reservations_page.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Displays the list of the current user's reservations fetched from

import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/my_reservations_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

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
                          slot: viewModel.reservations[index],
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

// ── Reservation card ─────────────────────────────────────────────────────────

class _ReservationCard extends StatelessWidget {
  final Map<String, dynamic> slot;

  const _ReservationCard({required this.slot});

  @override
  Widget build(BuildContext context) {
    final String date = slot['date'] ?? '';
    // start_time comes as "HH:mm:ss" – show only "HH:mm"
    final String startTime = (slot['start_time'] as String? ?? '').length >= 5
        ? (slot['start_time'] as String).substring(0, 5)
        : slot['start_time'] ?? '';
    final int duration = slot['duration'] ?? 0;
    final String note = slot['note'] ?? '';
    final bool isOnline = slot['is_online'] == 1 || slot['is_online'] == true;

    return Container(
      decoration: constants.squircleShadow(
        hasBorder: true,
        color: constants.background,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Header: date + online/in-person badge ────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  svgs.icon("calendar", constants.primary, width: 32),
                  const SizedBox(width: 8),
                  Text(
                    date.replaceAll("-", "."),
                    style: TextStyle(
                      fontWeight: constants.fwSemiBold,
                      fontSize: constants.fsTitle,
                      color: constants.darkGrey,
                    ),
                  ),
                ],
              ),
              _ModeBadge(isOnline: isOnline),
            ],
          ),

          const SizedBox(height: 12),

          // ── Time + duration ───────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  svgs.icon("clock", constants.darkGrey, width: 24),
                  const SizedBox(width: 4),
                  Text(
                    startTime,
                    style: TextStyle(
                      fontSize: constants.fsBody,
                      color: constants.darkGrey,
                    ),
                  ),
                ],
              ),
              Text(
                "  -  ",
                style: TextStyle(
                  fontSize: constants.fsHeadline,
                  color: constants.darkGrey,
                ),
              ),
              Row(
                children: [
                  svgs.icon("hourglass", constants.darkGrey, width: 24),
                  const SizedBox(width: 4),
                  Text(
                    "$duration min",
                    style: TextStyle(
                      fontSize: constants.fsBody,
                      color: constants.darkGrey,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12),
            ],
          ),

          // ── Note / reason ─────────────────────────────────────────────────
          if (note.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                svgs.icon("pencil", constants.darkGrey, width: 24),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    note,
                    style: TextStyle(
                      fontSize: constants.fsBody,
                      color: constants.darkGrey,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Mode badge (Online / In-person) ──────────────────────────────────────────

class _ModeBadge extends StatelessWidget {
  final bool isOnline;

  const _ModeBadge({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return isOnline
        ? svgs.icon('screen', constants.primary, width: 32)
        : svgs.icon('location', constants.primary, width: 32);
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

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
            const SizedBox(height: 6),
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
