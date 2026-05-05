// settings_dialogs.dart
// Dialog functions for the settings page. Kept as plain async functions
// so they carry no widget state of their own.

import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/change_settings_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';

Future<void> showNameDialog(
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
          CustomInputTextField(controller: nameCtrl, hintText: "Name", maxLength: 50),
          const SizedBox(height: 12),
          CustomInputTextField(controller: surnameCtrl, hintText: "Surname", maxLength: 50),
        ],
      ),
      actions: [
        _cancelButton(ctx),
        TextButton(
          onPressed: () async {
            FocusScope.of(context).unfocus();
            await vm.updateName(nameCtrl.text.trim(), surnameCtrl.text.trim());
            if (ctx.mounted) Navigator.pop(ctx);
          },
          child: _saveLabel(),
        ),
      ],
    ),
  );
}

Future<void> showVisitReasonDialog(
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
      content: CustomInputTextField(
        controller: ctrl,
        hintText: "Reason for visit",
        maxLength: 50,
      ),
      actions: [
        _cancelButton(ctx),
        TextButton(
          onPressed: () async {
            FocusScope.of(context).unfocus();
            await vm.updateVisitReason(ctrl.text.trim());
            if (ctx.mounted) Navigator.pop(ctx);
          },
          child: _saveLabel(),
        ),
      ],
    ),
  );
}

Future<void> showCreateTeacherDialog(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            CustomInputTextField(controller: emailCtrl, hintText: "Email", maxLength: 50),
            const SizedBox(height: 12),
            CustomInputTextField(controller: nameCtrl, hintText: "First name", maxLength: 50),
            const SizedBox(height: 12),
            CustomInputTextField(controller: surnameCtrl, hintText: "Last name", maxLength: 50),
            if (errorMsg != null) ...[
              const SizedBox(height: 10),
              Text(errorMsg!, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: loading ? null : () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: constants.darkGrey150)),
          ),
          TextButton(
            onPressed: loading
                ? null
                : () async {
                    final email = emailCtrl.text.trim();
                    final name = nameCtrl.text.trim();
                    final surname = surnameCtrl.text.trim();

                    if (email.isEmpty || name.isEmpty || surname.isEmpty) {
                      setDialogState(() => errorMsg = "All fields are required.");
                      return;
                    }

                    setDialogState(() { loading = true; errorMsg = null; });

                    final success = await vm.createTeacher(email, name, surname);

                    if (ctx.mounted) {
                      if (success) {
                        Navigator.pop(ctx);
                        notify.showToast("Teacher created successfully");
                      } else {
                        setDialogState(() {
                          loading = false;
                          errorMsg = "Failed. User may already be registered";
                        });
                      }
                    }
                  },
            child: loading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: constants.primary),
                  )
                : _saveLabel(label: "Create"),
          ),
        ],
      ),
    ),
  );
}

// ─── Shared dialog helpers ───────────────────────────────────────────────────

Widget _cancelButton(BuildContext ctx) => TextButton(
      onPressed: () => Navigator.pop(ctx),
      child: Text("Cancel", style: TextStyle(color: constants.darkGrey150)),
    );

Widget _saveLabel({String label = "Save"}) => Text(
      label,
      style: TextStyle(color: constants.primary, fontWeight: constants.fwSemiBold),
    );
