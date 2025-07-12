import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ut_ad_leika/infrastructure/core/platform/platform_detector.dart';
import 'package:ut_ad_leika/presentation/core/widgets/molecules/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/organisms/import.dart';

class PlayScaffold extends StatelessWidget {
  final PlayAppBar? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final BottomButtonsDefinition? bottomButtons;
  final Widget child;

  const PlayScaffold({
    super.key,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomButtons,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformDetector.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: appBar?.toCupertino(),
        child: _cupertinoChild(child),
      );
    }
    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomButtons == null
          ? null
          : PlayBottomButtons(
              buttons: bottomButtons!,
              shouldPushOnKeyboard: bottomButtons?.shouldPushOnKeyboard ?? true,
            ),
      body: child,
    );
  }

  Widget _cupertinoChild(Widget child) {
    if (bottomButtons == null) {
      return child;
    }
    return Column(
      children: [
        Expanded(child: child),
        PlayBottomButtons(
          buttons: bottomButtons!,
          shouldPushOnKeyboard: bottomButtons?.shouldPushOnKeyboard ?? true,
        ),
      ],
    );
  }
}
