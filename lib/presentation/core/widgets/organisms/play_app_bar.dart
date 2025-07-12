import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ut_ad_leika/infrastructure/core/platform/platform_detector.dart';
import 'package:ut_ad_leika/presentation/core/widgets/atoms/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/import.dart';

class AppBarActionDefinition {
  final IconData icon;
  final void Function() onTap;

  AppBarActionDefinition({required this.icon, required this.onTap});

  Widget toWidget() {
    return PlayTapVisual(
      onTap: onTap,
      child: PlayPadding.all(
        value: PlatformDetector.isIOS ? 0 : PlayPaddings.medium,
        child: PlayIcon(
          icon,
          size: PlaySizes.large,
          color: PlayTheme.onPrimary(),
        ),
      ),
    );
  }
}

class PlayAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBack;
  final bool takesUpSpace;
  final AppBarActionDefinition? action;

  @override
  Size get preferredSize => takesUpSpace ? const Size.fromHeight(kToolbarHeight) : Size.zero;

  const PlayAppBar({
    super.key,
    this.title,
    this.showBack = true,
    this.takesUpSpace = true,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      systemOverlayStyle: takesUpSpace ? PlayTheme.chrome : PlayTheme.chromeNoSpace,
      actions: action != null ? [action!.toWidget()] : [],
      leading: showBack
          ? InkWell(
              onTap: Navigator.of(context).pop,
              child: PlayIcon(Icons.arrow_back, color: PlayTheme.onPrimary()),
            )
          : null,
      title: title == null ? null : PlayText(title!, style: TextStyle(color: PlayTheme.onPrimary())),
      backgroundColor: PlayTheme.primary(),
    );
  }

  PlayCupertinoAppBar toCupertino() {
    return PlayCupertinoAppBar(
      title: title,
      showBack: showBack,
      takesUpSpace: takesUpSpace,
      action: action,
    );
  }
}

class PlayCupertinoAppBar extends StatelessWidget implements ObstructingPreferredSizeWidget {
  final String? title;
  final bool showBack;
  final bool takesUpSpace;
  final AppBarActionDefinition? action;

  @override
  Size get preferredSize => takesUpSpace ? const Size.fromHeight(44) : Size.zero;

  const PlayCupertinoAppBar({
    super.key,
    this.title,
    this.showBack = true,
    this.takesUpSpace = true,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    if (!takesUpSpace) {
      return const PlaySizedBox.shrink();
    }
    return CupertinoNavigationBar(
      middle: title == null
          ? null
          : PlayText(
              title!,
              style: PlayTheme.onPrimary().text,
            ),
      backgroundColor: PlayTheme.primary(),
      automaticBackgroundVisibility: false,
      trailing: action?.toWidget(),
    );
  }

  @override
  bool shouldFullyObstruct(BuildContext context) {
    return true;
  }
}
