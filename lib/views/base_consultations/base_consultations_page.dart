// base_consultations_page.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Shared consultation list page used by both student and owner views.
// Accepts optional action widgets so each caller can inject role-specific
// controls without duplicating the surrounding layout.

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/base_consultations_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'room_selector_button.dart';
import 'content_consultations.dart';

class BaseConsultationsPage extends StatefulWidget {
  final Widget? toggle;
  final Widget? addButton;
  final Widget? deleteButton;
  final BaseConsultationsViewmodel? viewModel;
  // Builder callbacks are nullable
  final Widget Function(int blockId)? editBlockButton;
  final Widget? Function(int slotId, int blockId, Color color)?
  showHistoryOption;
  final Widget? Function(int blockId, bool isEmpty)? addSlotBefore;
  final Widget? Function(int blockId, bool isEmpty)? addSlotAfter;
  const BaseConsultationsPage({
    super.key,
    this.viewModel,
    this.toggle,
    this.addButton,
    this.deleteButton,
    this.editBlockButton,
    this.showHistoryOption,
    this.addSlotBefore,
    this.addSlotAfter,
  });
  @override
  State<BaseConsultationsPage> createState() => _BaseConsultationsPageState();
}

class _BaseConsultationsPageState extends State<BaseConsultationsPage> {
  late final BaseConsultationsViewmodel _viewModel;
  @override
  void initState() {
    super.initState();
    // If the caller provides its own viewModel (e.g. owner page), reuse it;
    // otherwise create a default one and run init() to fetch initial data
    _viewModel = widget.viewModel ?? BaseConsultationsViewmodel();
    if (widget.viewModel == null) _viewModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBarMenu(
          viewModel: _viewModel,
          toggle: widget.toggle,
          onHomePage: true,
        ),
        drawer: SliderMenu(),
        backgroundColor: constants.background,
        body: Consumer<BaseConsultationsViewmodel>(
          builder: (context, viewModel, child) {
            return SafeArea(
              child: Center(
                child: ConstrainedBox(
                  // Cap content width for readability on tablets and wide screens
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: RefreshIndicator(
                    color: constants.primary,
                    onRefresh: () => viewModel.loadRoom(),
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        overscroll: false,
                      ),
                      child: ListView(
                        children: [
                          const SizedBox(height: 100),
                          StickyHeader(
                            // RoomSelectorButton stays pinned while the list scrolls
                            header: RoomSelectorButton(viewModel: viewModel),
                            content: viewModel.isLoading
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 200,
                                    ),
                                    child: Center(
                                      child: SpinKitPouringHourGlass(
                                        color: constants.primary,
                                        size: constants.fsHeadline,
                                      ),
                                    ),
                                  )
                                : ConsultationsContent(
                                    viewModel: viewModel,
                                    link: viewModel.selectedRoom?.link,
                                    toggle: widget.toggle,
                                    addButton: widget.addButton,
                                    showHistoryOption: widget.showHistoryOption,
                                    deleteButton: widget.deleteButton,
                                    editBlockButton: widget.editBlockButton,
                                    addSlotBefore: widget.addSlotBefore,
                                    addSlotAfter: widget.addSlotAfter,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
