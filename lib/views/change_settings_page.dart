import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/change_settings_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ChangeSettings extends StatefulWidget {
  const ChangeSettings({super.key});

  @override
  State<ChangeSettings> createState() => _ChangeSettingsState();
}

class _ChangeSettingsState extends State<ChangeSettings> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = ChangeSettingsViewmodel();
        viewModel.initialize();
        return viewModel;
      },
      child: Consumer<ChangeSettingsViewmodel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBarMenu(onSettingsPage: true),
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
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Settings",
                            style: TextStyle(
                              fontSize: constants.fsHeadline,
                              fontWeight: constants.fwSemiBold,
                              color: constants.darkGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "View your profile and manage preferences",
                            style: TextStyle(
                              fontSize: constants.fsLabel,
                              color: constants.darkGrey150,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Container(
                            width: double.infinity,
                            decoration: constants.squircleShadow(
                              hasBorder: true,
                              color: constants.background,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _InfoTile(
                                  svgName: 'person',
                                  label: "Email",
                                  value: viewModel.email,
                                ),
                                _divider(),
                                _EditableTile(
                                  svgName: 'id',
                                  label: "Name",
                                  value:
                                      '${viewModel.name} ${viewModel.surname}',
                                  onEdit: () =>
                                      _showNameDialog(context, viewModel),
                                ),
                                _divider(),
                                _EditableTile(
                                  svgName: 'pencil',
                                  label: "Visit Reason",
                                  value: viewModel.visitReason.isEmpty
                                      ? "Not set"
                                      : viewModel.visitReason,
                                  onEdit: () => _showVisitReasonDialog(
                                    context,
                                    viewModel,
                                  ),
                                ),
                                _divider(),
                                _InfoTile(
                                  svgName: 'work',
                                  label: "Role",
                                  value: viewModel.role,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            decoration: constants.squircleShadow(
                              hasBorder: true,
                              color: constants.background,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    16,
                                    20,
                                    8,
                                  ),
                                  child: Text(
                                    "Preferences",
                                    style: TextStyle(
                                      fontSize: constants.fsLabel,
                                      fontWeight: constants.fwSemiBold,
                                      color: constants.darkGrey,
                                    ),
                                  ),
                                ),
                                Divider(color: constants.darkGrey30, height: 1),
                                _CheckboxTile(
                                  svgName: viewModel.visibility
                                      ? 'eye_open'
                                      : 'eye_closed',
                                  title: "Visibility",
                                  subtitle: "Show your name to others.",
                                  value: viewModel.visibility,
                                  onChanged: (_) => viewModel.setVisibility(),
                                ),
                                _NotifyHoursTile(viewModel: viewModel),
                                _CheckboxTile(
                                  svgName: themeSelector.isDark
                                      ? 'moon'
                                      : 'sun',
                                  title: "Theme",
                                  subtitle: "Switch to dark appearance.",
                                  value: themeSelector.isDark,
                                  onChanged: viewModel.setTheme,
                                ),
                              ],
                            ),
                          ),
                          if (viewModel.role == 'teacher') ...[
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              decoration: constants.squircleShadow(
                                hasBorder: true,
                                color: constants.background,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      16,
                                      20,
                                      8,
                                    ),
                                    child: Text(
                                      "Administration",
                                      style: TextStyle(
                                        fontSize: constants.fsLabel,
                                        fontWeight: constants.fwSemiBold,
                                        color: constants.darkGrey,
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    color: constants.darkGrey30,
                                    height: 1,
                                  ),
                                  _ActionTile(
                                    svgName: 'person',
                                    title: "Create Teacher",
                                    subtitle: "Register a new teacher account.",
                                    onTap: () => _showCreateTeacherDialog(
                                      context,
                                      viewModel,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _divider() => Divider(
    indent: 20,
    endIndent: 20,
    color: constants.darkGrey30,
    height: 1,
  );
  Future<void> _showNameDialog(
    BuildContext context,
    ChangeSettingsViewmodel vm,
  ) async {
    final nameCtrl = TextEditingController(text: vm.name);
    final surnameCtrl = TextEditingController(text: vm.surname);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: constants.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Edit Name",
          style: TextStyle(
            fontSize: constants.fsBody,
            fontWeight: constants.fwSemiBold,
            color: constants.darkGrey,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(nameCtrl, "First name"),
            const SizedBox(height: 12),
            _dialogField(surnameCtrl, "Last name"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Cancel",
              style: TextStyle(color: constants.darkGrey150),
            ),
          ),
          TextButton(
            onPressed: () async {
              await vm.updateName(
                nameCtrl.text.trim(),
                surnameCtrl.text.trim(),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(
              "Save",
              style: TextStyle(
                color: constants.primary,
                fontWeight: constants.fwSemiBold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showVisitReasonDialog(
    BuildContext context,
    ChangeSettingsViewmodel vm,
  ) async {
    final ctrl = TextEditingController(text: vm.visitReason);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: constants.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Visit Reason",
          style: TextStyle(
            fontSize: constants.fsBody,
            fontWeight: constants.fwSemiBold,
            color: constants.darkGrey,
          ),
        ),
        content: _dialogField(ctrl, "Reason for visit", maxLines: 3),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Cancel",
              style: TextStyle(color: constants.darkGrey150),
            ),
          ),
          TextButton(
            onPressed: () async {
              await vm.updateVisitReason(ctrl.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(
              "Save",
              style: TextStyle(
                color: constants.primary,
                fontWeight: constants.fwSemiBold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextField _dialogField(
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: TextStyle(fontSize: constants.fsLabel, color: constants.darkGrey),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: constants.darkGrey150,
          fontSize: constants.fsLabel,
        ),
        filled: true,
        fillColor: constants.darkGrey30,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
      ),
    );
  }

  Future<void> _showCreateTeacherDialog(
    BuildContext context,
    ChangeSettingsViewmodel vm,
  ) async {
    final emailCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final surnameCtrl = TextEditingController();
    bool loading = false;
    String? errorMsg;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: constants.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Create Teacher",
            style: TextStyle(
              fontSize: constants.fsBody,
              fontWeight: constants.fwSemiBold,
              color: constants.darkGrey,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(emailCtrl, "Email"),
              const SizedBox(height: 12),
              _dialogField(nameCtrl, "First name"),
              const SizedBox(height: 12),
              _dialogField(surnameCtrl, "Last name"),
              if (errorMsg != null) ...[
                const SizedBox(height: 10),
                Text(
                  errorMsg!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.pop(ctx),
              child: Text(
                "Cancel",
                style: TextStyle(color: constants.darkGrey150),
              ),
            ),
            TextButton(
              onPressed: loading
                  ? null
                  : () async {
                      final email = emailCtrl.text.trim();
                      final name = nameCtrl.text.trim();
                      final surname = surnameCtrl.text.trim();

                      if (email.isEmpty || name.isEmpty || surname.isEmpty) {
                        setDialogState(
                          () => errorMsg = "All fields are required.",
                        );
                        return;
                      }

                      setDialogState(() {
                        loading = true;
                        errorMsg = null;
                      });

                      final success = await vm.createTeacher(
                        email,
                        name,
                        surname,
                      );

                      if (ctx.mounted) {
                        if (success) {
                          Navigator.pop(ctx);
                          notify.showToast("Teacher created successfully");
                        } else {
                          setDialogState(() {
                            loading = false;
                            errorMsg =
                                "Failed. User may already be registered";
                          });
                        }
                      }
                    },
              child: loading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: constants.primary,
                      ),
                    )
                  : Text(
                      "Create",
                      style: TextStyle(
                        color: constants.primary,
                        fontWeight: constants.fwSemiBold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String svgName;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.svgName,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              svgs.icon(svgName, constants.primary, width: constants.fsTitle),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: constants.fsBody,
                        fontWeight: constants.fwSemiBold,
                        color: constants.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: constants.fsLabel,
                        color: constants.darkGrey150,
                        fontWeight: constants.fwRegular,
                      ),
                    ),
                  ],
                ),
              ),
              svgs.icon(
                'arrow_right',
                constants.darkGrey150,
                width: constants.fsBody,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String svgName;
  final String label;
  final String value;

  const _InfoTile({
    required this.svgName,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          svgs.icon(svgName, constants.primary, width: constants.fsTitle),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: constants.fsLabel,
                    color: constants.darkGrey150,
                    fontWeight: constants.fwRegular,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: constants.fsBody,
                    fontWeight: constants.fwSemiBold,
                    color: constants.darkGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableTile extends StatelessWidget {
  final String svgName;
  final String label;
  final String value;
  final VoidCallback onEdit;

  const _EditableTile({
    required this.svgName,
    required this.label,
    required this.value,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          svgs.icon(svgName, constants.primary, width: constants.fsTitle),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: constants.fsLabel,
                    color: constants.darkGrey150,
                    fontWeight: constants.fwRegular,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: constants.fsBody,
                    fontWeight: constants.fwSemiBold,
                    color: constants.darkGrey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: svgs.icon('edit', constants.primary, width: constants.fsBody),
            tooltip: "Edit",
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _CheckboxTile extends StatelessWidget {
  final String svgName;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _CheckboxTile({
    required this.svgName,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          svgs.icon(svgName, constants.primary, width: constants.fsTitle),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: constants.fsBody,
                    fontWeight: constants.fwSemiBold,
                    color: constants.darkGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: constants.fsLabel,
                    color: constants.darkGrey150,
                    fontWeight: constants.fwRegular,
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: value,
            activeColor: constants.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _NotifyHoursTile extends StatefulWidget {
  final ChangeSettingsViewmodel viewModel;
  const _NotifyHoursTile({required this.viewModel});

  @override
  State<_NotifyHoursTile> createState() => _NotifyHoursTileState();
}

class _NotifyHoursTileState extends State<_NotifyHoursTile> {
  late TextEditingController _ctrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.viewModel.notifyHoursBefore.toString(),
    );
  }

  @override
  void didUpdateWidget(_NotifyHoursTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newValue = widget.viewModel.notifyHoursBefore.toString();
    if (_ctrl.text != newValue) {
      _ctrl.text = newValue;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String val) {
    final parsed = int.tryParse(val);
    if (parsed == null || parsed < 0 || parsed > 1000) {
      setState(() => _error = "0–1000");
    } else {
      setState(() => _error = null);
      widget.viewModel.updateNotifyHoursBefore(parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          svgs.icon('clock', constants.primary, width: constants.fsTitle),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Notify me before",
                  style: TextStyle(
                    fontSize: constants.fsBody,
                    fontWeight: constants.fwSemiBold,
                    color: constants.darkGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "How early to receive a consultation reminder",
                  style: TextStyle(
                    fontSize: constants.fsLabel,
                    color: constants.darkGrey150,
                    fontWeight: constants.fwRegular,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 64,
            child: TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: constants.fsBody,
                fontWeight: constants.fwSemiBold,
                color: _error != null ? Colors.red : constants.primary,
              ),
              decoration: InputDecoration(
                suffixText: "h",
                suffixStyle: TextStyle(
                  fontSize: constants.fsLabel,
                  color: constants.darkGrey150,
                ),
                errorText: _error,
                errorStyle: const TextStyle(fontSize: 9, height: 0.8),
                filled: true,
                fillColor: constants.darkGrey30,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
              ),
              onChanged: _onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
