import 'package:flutter/cupertino.dart';
import 'package:vynthra/app/app_theme.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CustomLoadingWidget extends StatelessWidget {
  const CustomLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.discreteCircle(
        color: AppTheme.accentColor,
        size: 25,
      ),
    );
  }
}
