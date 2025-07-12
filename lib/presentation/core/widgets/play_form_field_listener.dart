import 'package:flutter/material.dart';
import 'package:ut_ad_leika/presentation/core/widgets/atoms/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/import.dart';

class PlayFormFieldListener extends StatelessWidget {
  final Widget child;
  final String fieldId;
  final FocusNode? focus;

  const PlayFormFieldListener({super.key, this.focus, required this.fieldId, required this.child});

  @override
  Widget build(BuildContext context) {
    return PlayEventBusListener(
      onMessage: (PlayFormFieldErrorEvent event) {
        if (event.fieldId == fieldId) {
          focus?.requestFocus();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              shape: PlayCornerRadius().drawer,
              content: PlayText(event.message, style: PlayTheme.font.body14.onError),
              behavior: SnackBarBehavior.floating,
              backgroundColor: PlayTheme.error(),
            ),
          );
        }
      },
      child: child,
    );
  }
}

@immutable
class PlayFormFieldErrorEvent {
  final String fieldId;
  final String message;

  const PlayFormFieldErrorEvent({required this.fieldId, required this.message});
}
