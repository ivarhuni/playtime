import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ut_ad_leika/infrastructure/core/platform/platform_detector.dart';
import 'package:ut_ad_leika/presentation/core/widgets/atoms/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/import.dart';

class PlayTextField extends StatefulWidget {
  final String fieldId;
  final String? title;
  final String hint;
  final bool optional;
  final TextEditingController? controller;
  final bool enabled;
  final bool showCard;
  final Color? hintColor;
  final FocusNode? focusNode;
  final IconData? actionIcon;
  final int? maxLength;
  final void Function(String input)? onChanged;

  const PlayTextField({
    super.key,
    this.title,
    required this.fieldId,
    required this.hint,
    this.optional = true,
    this.showCard = true,
    this.controller,
    this.enabled = true,
    this.hintColor,
    this.focusNode,
    this.actionIcon,
    this.onChanged,
    this.maxLength,
  });

  @override
  State<StatefulWidget> createState() {
    return _LaTextField();
  }
}

class _LaTextField extends State<PlayTextField> {
  late final FocusNode _fallbackFocusNode;

  @override
  void initState() {
    super.initState();

    if (widget.focusNode == null) {
      _fallbackFocusNode = FocusNode();
    }
  }

  @override
  Widget build(BuildContext context) {
    late Widget text;
    if (PlatformDetector.isIOS) {
      text = PlayCard(
        type: CardType.secondary,
        child: PlayRow(
          children: [
            PlayExpanded(
              child: CupertinoTextField(
                enabled: widget.enabled,
                controller: widget.controller,
                onChanged: widget.onChanged,
                focusNode: widget.focusNode ?? _fallbackFocusNode,
                textCapitalization: TextCapitalization.sentences,
                placeholder: widget.hint,
                padding: const EdgeInsets.symmetric(vertical: PlayPaddings.mediumSmall, horizontal: PlayPaddings.medium),
                decoration: BoxDecoration(color: PlayTheme.secondaryContainer(), borderRadius: BorderRadius.circular(PlayCornerRadius.mediumSmall)),
                style: PlayTheme.font.body16.copyWith(color: PlayTheme.onSecondaryContainer()),
                placeholderStyle: PlayTheme.font.body16.copyWith(color: widget.hintColor ?? PlayTheme.hintText()),
                cursorColor: PlayTheme.primary(),
                maxLength: widget.maxLength,
              ),
            ),
            if (widget.actionIcon != null)
              PlayPadding(
                padding: const EdgeInsets.only(right: PlayPaddings.mediumSmall),
                child: PlayCenter(
                  child: PlayIcon(widget.actionIcon!, size: PlaySizes.Playrge, color: widget.hintColor),
                ),
              ),
          ],
        ),
      );
    } else {
      text = PlayCard(
        type: CardType.secondary,
        child: PlayRow(
          children: [
            PlayExpanded(
              child: TextField(
                enabled: widget.enabled,
                controller: widget.controller,
                onChanged: widget.onChanged,
                focusNode: widget.focusNode ?? _fallbackFocusNode,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: TextStyle(color: widget.hintColor ?? PlayTheme.hintText()),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: PlayPaddings.mediumSmall,
                    horizontal: PlayPaddings.medium,
                  ),
                  counterText: "",
                ),
                style: PlayTheme.font.body16.copyWith(color: PlayTheme.onSecondaryContainer()),
                cursorColor: PlayTheme.primary(),
                maxLength: widget.maxLength,
              ),
            ),
            if (widget.actionIcon != null)
              PlayPadding(
                padding: const EdgeInsets.only(right: PlayPaddings.mediumSmall),
                child: PlayCenter(
                  child: PlayIcon(widget.actionIcon!, size: PlaySizes.Playrge, color: widget.hintColor),
                ),
              ),
          ],
        ),
      );
    }

    Widget finalWidget = text;
    if (widget.showCard) {
      finalWidget = PlayCard(
        child: PlayPadding.all(
          value: PlayPaddings.medium,
          child: PlayColumn(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PlayRow(
                children: [
                  if (widget.title != null) PlayExpanded(child: PlayText(widget.title!, style: PlayTheme.font.body14.light)),
                  if (!widget.optional) PlayText("*${S.of(context).global_required}", style: PlayTheme.font.body12.light.primary),
                ],
              ),
              const PlaySizedBox(height: PlayPaddings.small),
              finalWidget,
            ],
          ),
        ),
      );
    }

    return PlayFormFieldListener(
      fieldId: widget.fieldId,
      focus: widget.focusNode ?? _fallbackFocusNode,
      child: finalWidget,
    );
  }
}
