import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ut_ad_leika/presentation/core/widgets/atoms/import.dart' hide PlayPadding;
import 'package:ut_ad_leika/presentation/core/widgets/atoms/play_padding.dart';
import 'package:ut_ad_leika/presentation/core/widgets/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/molecules/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/templates/import.dart';

enum BottomButtonsStyle { sideBySide, sandwich }

@immutable
class BottomButtonsDefinition extends Equatable {
  final String drawerHeading;
  final BottomButtonsStyle type;
  final bool loading;
  final bool showDropShadow;
  final List<BottomButtonDefinition> buttons;
  final Widget? aboveButtonsWidget;
  final bool addBottomPadding;
  final bool exit;
  final bool shouldPushOnKeyboard;
  final Color? background;

  const BottomButtonsDefinition({
    this.buttons = const [],
    this.aboveButtonsWidget,
    this.addBottomPadding = true,
    this.showDropShadow = true,
    this.type = BottomButtonsStyle.sideBySide,
    this.drawerHeading = "",
    this.background,
    this.loading = false,
    this.exit = false,
    this.shouldPushOnKeyboard = true,
  });

  @override
  List<Object?> get props => [
    drawerHeading,
    type,
    loading,
    buttons,
    aboveButtonsWidget,
    exit,
    shouldPushOnKeyboard,
    background,
    addBottomPadding,
    showDropShadow,
  ];
}

@immutable
class BottomButtonDefinition extends Equatable {
  final String text;
  final String? drawerText;
  final IconData? icon;
  final bool enabled;
  final bool busy;
  final Key? key;
  final void Function() onTap;
  final void Function()? onDisabledTap;

  const BottomButtonDefinition({
    required this.text,
    required this.onTap,
    this.drawerText,
    this.enabled = true,
    this.busy = false,
    this.icon,
    this.onDisabledTap,
    this.key,
  });

  factory BottomButtonDefinition.empty() {
    return BottomButtonDefinition(text: "", onTap: () {});
  }

  @override
  List<Object?> get props => [key, text, drawerText, icon, enabled, busy, onTap, onDisabledTap];
}

class PlayBottomButtons extends StatefulWidget {
  static const Key bottomButtonsMoreButtonKey = Key("bottomButtonsMoreButtonKey");
  static double bottomPadding = PlayPaddings.medium;

  final BottomButtonsDefinition buttons;

  final bool shouldPushOnKeyboard;

  static double getBottomButtonsHeight({BottomButtonsStyle style = BottomButtonsStyle.sideBySide}) {
    return switch (style) {
      BottomButtonsStyle.sideBySide => PlayButton.buttonHeight + PlayPaddings.bottomPadding + bottomPadding,
      BottomButtonsStyle.sandwich => (PlayButton.buttonHeight * 2) + (PlayPaddings.bottomPadding * 3) + bottomPadding,
    };
  }

  const PlayBottomButtons({super.key, required this.buttons, this.shouldPushOnKeyboard = true});

  @override
  State<StatefulWidget> createState() {
    return _LaBottomButtonsState();
  }
}

class _LaBottomButtonsState extends State<PlayBottomButtons> with WidgetsBindingObserver, TickerProviderStateMixin {
  BottomButtonsDefinition get _buttons => widget.buttons;

  @override
  Widget build(BuildContext context) {
    if (widget.buttons.buttons.isEmpty && widget.buttons.aboveButtonsWidget == null) {
      return const PlaySizedBox.shrink();
    }

    final double padding = MediaQuery.of(context).padding.bottom;
    if (padding < PlayPaddings.extraLarge) {
      PlayBottomButtons.bottomPadding = padding + PlayPaddings.medium;
    } else {
      PlayBottomButtons.bottomPadding = padding + PlayPaddings.extraSmall;
    }

    final bool padBottom =
        (widget.buttons.buttons.isNotEmpty || widget.buttons.aboveButtonsWidget != null) &&
        widget.buttons.addBottomPadding;

    return Material(
      color: widget.buttons.background ?? PlayTheme.background(),
      child: PlayColumn(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.buttons.aboveButtonsWidget == null) const PlaySizedBox(height: PlayPaddings.small),

          widget.buttons.aboveButtonsWidget ?? const PlaySizedBox.shrink(),

          if (widget.buttons.buttons.isNotEmpty)
            PlayPadding(
              padding: const EdgeInsets.only(left: PlayPaddings.medium, right: PlayPaddings.medium),
              child: PlaySizedBox(width: double.infinity, child: _getMainButtonEntries(context)),
            ),

          if (padBottom) PlaySizedBox(height: PlayBottomButtons.bottomPadding),

          // Pushes buttons up for keyboard
          if (widget.shouldPushOnKeyboard && padBottom)
            PlaySizedBox(height: max(0, MediaQuery.of(context).viewInsets.bottom)),
        ],
      ),
    );
  }

  Widget _getMainButtonEntries(BuildContext context) {
    switch (widget.buttons.type) {
      case BottomButtonsStyle.sideBySide:
        return IntrinsicHeight(
          child: PlayRow(crossAxisAlignment: CrossAxisAlignment.stretch, children: _getSideBySideButtons(context)),
        );
      case BottomButtonsStyle.sandwich:
        return PlaySeparatedColumn(
          separatorBuilder: (BuildContext context, int index) {
            return const PlaySizedBox(height: PlayPaddings.medium);
          },
          mainAxisSize: MainAxisSize.min,
          children: [..._getSandwichButtons(context)],
        );
    }
  }

  List<Widget> _getSandwichButtons(BuildContext context) {
    return _buttons.buttons.map((BottomButtonDefinition button) {
      final int index = _buttons.buttons.indexOf(button);
      return _loadingIndicator(
        child: PlayButton(
          key: button.key,
          buttonStyle: index == 0 ? PlayButtonStyle.primary : PlayButtonStyle.secondary,
          text: button.text,
          maxLines: 1,
          onTap: button.onTap,
          enabled: button.enabled,
          busy: button.busy,
          onDisabledTap: button.onDisabledTap,
        ),
      );
    }).toList();
  }

  List<Widget> _getSideBySideButtons(BuildContext context) {
    int flex = 50;
    int overflowFlex = 18;
    if (_buttons.buttons.length > 2) {
      flex = 41;
    }

    if (Accessibility.of(context).isInAccessibilityMode) {
      overflowFlex = 20;
      flex = 100;
      if (_buttons.buttons.length > 1) {
        flex = 80;
      }
    }

    final List<Widget> entries = [];
    int cnt = 0;
    for (final BottomButtonDefinition button in _buttons.buttons) {
      if (Accessibility.of(context).isInAccessibilityMode && cnt > 0) {
        break;
      }
      if (cnt > 1) {
        break;
      }
      if (cnt > 0) {
        entries.add(const PlaySizedBox(width: PlayPaddings.small));
      }
      cnt++;
      entries.add(
        PlayFlexible(
          flex: flex,
          child: _loadingIndicator(
            child: PlayButton(
              key: button.key,
              text: button.text,
              buttonStyle: cnt == 1 ? PlayButtonStyle.primary : PlayButtonStyle.secondary,
              maxLines: 2,
              onTap: button.onTap,
              enabled: button.enabled,
              busy: button.busy,
              onDisabledTap: button.onDisabledTap,
            ),
          ),
        ),
      );
    }
    final bool shouldDisplayMoreButton =
        _buttons.buttons.length > 2 || (Accessibility.of(context).isInAccessibilityMode && _buttons.buttons.length > 1);
    if (shouldDisplayMoreButton) {
      entries.add(const PlaySizedBox(width: PlayPaddings.small));
      entries.add(
        PlayFlexible(
          flex: overflowFlex,
          child: _loadingIndicator(
            child: PlayButton(
              key: PlayBottomButtons.bottomButtonsMoreButtonKey,
              onTap: () => _showOverflowOptions(context),
              buttonStyle: PlayButtonStyle.secondary,
              icon: PlayIcons.more,
            ),
          ),
        ),
      );
    }

    return entries.reversed.toList();
  }

  Widget _loadingIndicator({required Widget child}) {
    if (widget.buttons.loading) {
      return IgnorePointer(
        child: PlayLoadingBox(child: PlayPadding.all(value: 1, child: child)),
      );
    }
    return child;
  }

  Widget _getIgnorePointer({required Widget child}) {
    return IgnorePointer(child: child);
  }

  TextStyle _getButtonTextStyle({required BuildContext context}) {
    final TextStyle regular = PlayTheme.font.body16.bold;
    final Accessibility accessibility = Accessibility.of(context);
    switch (accessibility.size) {
      case AccessibilitySize.small:
      case AccessibilitySize.normal:
      case AccessibilitySize.Playrge:
        return regular;
      case AccessibilitySize.huge:
        return PlayTheme.font.body12;
    }
  }

  TextStyle _getHeadingTextStyle({required BuildContext context}) {
    final TextStyle regular = PlayTheme.font.body20.bold;
    final Accessibility accessibility = Accessibility.of(context);
    switch (accessibility.size) {
      case AccessibilitySize.small:
      case AccessibilitySize.normal:
      case AccessibilitySize.Playrge:
        return regular;
      case AccessibilitySize.huge:
        return PlayTheme.font.body16;
    }
  }

  Widget _excludeMainSemantics({required Widget child, required bool excludeChildren}) {
    if (!MediaQuery.of(context).accessibleNavigation) {
      return child;
    }
    return ExcludeSemantics(child: child);
  }

  void _showOverflowOptions(BuildContext context) {
    List<BottomButtonDefinition> overflowing = [];
    if (Accessibility.of(context).isInAccessibilityMode) {
      if (widget.buttons.buttons.length == 1) {
        return;
      }
      overflowing = widget.buttons.buttons.sublist(1);
    } else {
      if (widget.buttons.buttons.length == 2) {
        return;
      }
      overflowing = widget.buttons.buttons.sublist(2);
    }

    PlayBottomDrawer.show(
      context: context,
      config: BottomDrawerConfig(
        heading: S.of(context).global_more,
        entries: overflowing
            .map((BottomButtonDefinition e) => BottomDrawerEntry(text: e.text, onTap: e.onTap, icon: e.icon))
            .toList(),
      ),
    );
  }
}
