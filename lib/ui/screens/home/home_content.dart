import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:diabetes_app/ui/widgets/snack_bars/awesome_snack_bar.dart';

import '../../view_models/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            viewModel.welcomeMessage,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              context.read<HomeViewModel>().loadUserData();
              //uzywajcie tego snack baru pleaseee
              SnackbarUtils.showAwesomeSnackbar(
                context,
                title: "Success",
                message: "Data loaded successfully",
                contentType: ContentType.success,
              );
            },
            child: const Text("Load Data"),
          ),
        ],
      ),
    );
  }
}
