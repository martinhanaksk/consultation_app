import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/provide_feedback_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProvideFeedback extends StatefulWidget {
  const ProvideFeedback({super.key});

  @override
  State<ProvideFeedback> createState() => _ProvideFeedbackState();
}

class _ProvideFeedbackState extends State<ProvideFeedback> {
  String? token = "";
  String? email = "";
  bool? isTeacher;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProvideFeedbackViewmodel(),
      child: Consumer<ProvideFeedbackViewmodel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBarMenu(),
            drawer: SliderMenu(),
            backgroundColor: constants.bgLight,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(child: Text("Provide Feedback")),
              ),
            ),
          );
        },
      ),
    );
  }
}
