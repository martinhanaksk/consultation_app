import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/display_users_in_room_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DisplayUsersInRoomPage extends StatefulWidget {
  final int roomId;
  final String roomName;

  const DisplayUsersInRoomPage({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  @override
  State<DisplayUsersInRoomPage> createState() => _DisplayUsersInRoomPageState();
}

class _DisplayUsersInRoomPageState extends State<DisplayUsersInRoomPage> {
  late final DisplayUsersInRoomViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DisplayUsersInRoomViewModel();
    _initialize();
  }

  void _initialize() async {
    await _viewModel.init(widget.roomId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<DisplayUsersInRoomViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: constants.background,
            appBar: AppBarMenu(),
            body: SafeArea(child: _buildBody(context, viewModel)),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    DisplayUsersInRoomViewModel viewModel,
  ) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Failed to load users',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: _initialize, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (viewModel.users.isEmpty) {
      return Center(
        child: Text(
          'No users in this room yet',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: constants.grey),
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
                'Members',
                style: TextStyle(color: constants.darkGrey,fontSize: constants.fsBody),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: constants.squircleShadow(
                  color: constants.background,
                  hasBorder: true,
                ),
                child: Text(
                  '${viewModel.users.length}',
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
            itemCount: viewModel.users.length,
            itemBuilder: (context, index) {
              final email = viewModel.users[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: constants.squircleShadow(
                  color: constants.background,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: constants.lightPrimary,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          email.isNotEmpty ? email[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: constants.primary,
                            fontWeight: constants.fwSemiBold,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: constants.fsLabel,
                          fontWeight: constants.fwSemiBold,
                          color: constants.darkGrey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
