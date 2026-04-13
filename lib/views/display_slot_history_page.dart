import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/display_slot_history_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class DisplaySlotHistoryPage extends StatefulWidget {
  final String history;

  const DisplaySlotHistoryPage({super.key, required this.history});

  @override
  State<DisplaySlotHistoryPage> createState() => _DisplaySlotHistoryPageState();
}

class _DisplaySlotHistoryPageState extends State<DisplaySlotHistoryPage> {
  late final DisplaySlotHistoryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DisplaySlotHistoryViewModel();
    _viewModel.init(widget.history);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<DisplaySlotHistoryViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: constants.background,
            appBar: AppBarMenu(),
            body: SafeArea(child: displayHistoryBody(context, viewModel)),
          );
        },
      ),
    );
  }

  Widget displayHistoryBody(
    BuildContext context,
    DisplaySlotHistoryViewModel viewModel,
  ) {
    if (viewModel.isLoading) {
      return Center(
        child: SpinKitPouringHourGlass(
          color: constants.primary,
          size: constants.fsHeadline,
        ),
      );
    }

    if (viewModel.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Failed to load history',
              style: TextStyle(color: constants.darkGrey.withAlpha(150)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => viewModel.init(widget.history),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (viewModel.historyItems.isEmpty) {
      return Center(
        child: Text(
          'No history available',
          style: TextStyle(color: constants.darkGrey.withAlpha(150)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Slot History',
                style: TextStyle(
                  fontWeight: constants.fwSemiBold,
                  fontSize: constants.fsTitle,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: constants.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  '${viewModel.historyItems.length}',
                  style: TextStyle(
                    color: constants.primary,
                    fontWeight: constants.fwSemiBold,
                    fontSize: constants.fsLabel,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: viewModel.historyItems.length,
            itemBuilder: (context, index) {
              final item = viewModel.historyItems[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: constants.squircleShadow(
                  color: constants.background,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: constants.primary.withAlpha(30),
                    child: Icon(Icons.history, color: constants.primary),
                  ),
                  title: Text(
                    item.user,
                    style: TextStyle(
                      fontWeight: constants.fwSemiBold,
                      fontSize: constants.fsLabel,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: item.date.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: constants.fsLabel,
                                color: constants.darkGrey.withAlpha(150),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item.date,
                                style: TextStyle(
                                  color: constants.darkGrey.withAlpha(150),
                                  fontSize: constants.fsLabel,
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
