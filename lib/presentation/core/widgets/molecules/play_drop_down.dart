import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ut_ad_leika/infrastructure/core/platform/platform_detector.dart';
import 'package:ut_ad_leika/presentation/core/widgets/atoms/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/molecules/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/organisms/import.dart';

class PlayDropDown<T> extends StatefulWidget {
  final String fieldId;
  final String title;
  final List<T> options;
  final T? freeFormOption;
  final String? freeFormFieldId;
  final String? hint;
  final String? customHint;
  final bool optional;
  final String? explanation;
  final void Function(dynamic selected, String? customInput) onChanged;

  const PlayDropDown({
    super.key,
    required this.fieldId,
    required this.title,
    required this.options,
    this.freeFormOption,
    this.freeFormFieldId,
    required this.onChanged,
    this.hint,
    this.customHint,
    this.optional = true,
    this.explanation,
  });

  @override
  _LaDropDownState createState() => _LaDropDownState<T>();
}

class _LaDropDownState<T> extends State<PlayDropDown> {
  T? _selectedOption;
  String? _customInput = "";
  final FocusNode _customInputFocusNode = FocusNode();

  @override
  void dispose() {
    _customInputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (PlatformDetector.isIOS) {
      child = _getCupertinoPicker(context);
    } else {
      child = _getMaterialPicker(context);
    }

    return PlayFormFieldListener(fieldId: widget.fieldId, child: child);
  }

  Widget _getCupertinoPicker(BuildContext context) {
    return PlayCard(
      child: PlayPadding.all(
        value: PlayPaddings.medium,
        child: PlayColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _getTitle(context),
            const PlaySizedBox(height: PlayPaddings.small),
            PlayColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PlaySizedBox(height: PlayPaddings.extraSmall),
                PlayTapVisual(
                  onTap: () => _showCupertinoPicker(context),
                  child: PlayCard(
                    type: CardType.secondary,
                    child: PlayTextField(
                      fieldId: widget.fieldId,
                      optional: false,
                      showCard: false,
                      hint: _selectedOption?.toString() ?? widget.hint ?? "",
                      hintColor: _selectedOption == null ? PlayTheme.hintText() : PlayTheme.onSecondaryContainer(),
                      actionIcon: PlayIcons.dropDown,
                      enabled: false,
                    ),
                  ),
                ),
              ],
            ),
            _getFreeFormOption(context),
          ],
        ),
      ),
    );
  }

  Widget _getMaterialPicker(BuildContext context) {
    return PlayCard(
      child: PlayPadding.all(
        value: PlayPaddings.medium,
        child: PlayColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _getTitle(context),
            const PlaySizedBox(height: PlayPaddings.small),
            PlayColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PlaySizedBox(height: PlayPaddings.extraSmall),
                PlayCard(
                  type: CardType.secondary,
                  child: PlayPadding(
                    padding: const EdgeInsets.only(left: PlayPaddings.medium, right: PlayPaddings.small),
                    child: DropdownButton<T>(
                      value: _selectedOption,
                      borderRadius: const BorderRadius.all(Radius.circular(PlayCornerRadius.medium)),
                      elevation: PlayElevation.medium.toInt(),
                      hint: PlayText(widget.hint ?? "", style: PlayTheme.font.body16.hintText),
                      underline: const PlaySizedBox.shrink(),
                      isExpanded: true,
                      onChanged: (T? value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _selectedOption = value;
                          if (_selectedOption != widget.freeFormOption) {
                            _customInput = "";
                          }
                          widget.onChanged(_selectedOption, _customInput);
                          if (_selectedOption == widget.freeFormOption) {
                            _customInputFocusNode.requestFocus();
                          }
                        });
                      },
                      items: [
                        ...widget.options.map((dynamic option) {
                          return DropdownMenuItem<T>(
                            value: option as T,
                            child: PlayText(option.toString(), style: PlayTheme.font.body16),
                          );
                        }),
                        if (widget.freeFormOption != null)
                          DropdownMenuItem<T>(
                            value: widget.freeFormOption as T,
                            child: PlayText(widget.freeFormOption!.toString(), style: PlayTheme.font.body16),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            _getFreeFormOption(context),
          ],
        ),
      ),
    );
  }

  Widget _getFreeFormOption(BuildContext context) {
    if (_selectedOption == widget.freeFormOption && widget.freeFormOption != null && widget.freeFormFieldId != null) {
      return PlayPadding(
        padding: const EdgeInsets.only(top: PlayPaddings.mediumSmall),
        child: PlayTextField(
          fieldId: widget.freeFormFieldId!,
          showCard: false,
          focusNode: _customInputFocusNode,
          hint: widget.customHint ?? "",
          onChanged: (String input) => widget.onChanged(_selectedOption, input),
        ),
      );
    }
    return const PlaySizedBox.shrink();
  }

  Future<void> _showCupertinoPicker(BuildContext context) async {
    int initialIndex = widget.options.indexOf(_selectedOption ?? widget.options.first);
    if (_selectedOption == widget.freeFormOption) {
      initialIndex = widget.options.length;
    }
    final FixedExtentScrollController scrollController = FixedExtentScrollController(initialItem: initialIndex);

    final dynamic result = await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => PlayContainer(
        height: PlaySizes.dropdownHeight,
        decoration: BoxDecoration(
          color: PlayTheme.surface(),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20), // Rounded top corners
          ),
        ),
        child: PlayColumn(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: CupertinoButton(
                child: PlayText(S.of(context).global_done, style: PlayTheme.font.body16.primary),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            PlayExpanded(
              child: CupertinoPicker(
                scrollController: scrollController,
                backgroundColor: PlayTheme.surface(),
                itemExtent: 40,
                onSelectedItemChanged: (int index) {
                  setState(() {
                    if (index < widget.options.length) {
                      _selectedOption = widget.options[index] as T;
                      _customInput = "";
                    } else {
                      _selectedOption = widget.freeFormOption as T;
                    }
                  });
                },
                children: [
                  ...widget.options.map(
                    (dynamic option) => PlayCenter(child: PlayText((option as T).toString(), style: PlayTheme.font.body16)),
                  ),
                  if (widget.freeFormOption != null)
                    PlayCenter(child: PlayText(widget.freeFormOption!.toString(), style: PlayTheme.font.body16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (result != true && _selectedOption == widget.freeFormOption) {
      _customInputFocusNode.requestFocus();
    } else if (result == true && _selectedOption == widget.freeFormOption) {
      _customInputFocusNode.requestFocus();
    } else if (_selectedOption == null) {
      setState(() {
        _selectedOption = widget.options.first as T;
      });
    }

    widget.onChanged(_selectedOption, _customInput);
  }

  Widget _getTitle(BuildContext context) {
    return PlayRow(
      children: [
        PlayExpanded(
          child: PlayTapVisual(
            onTap: () =>
                PlayConfirmationDialog.show(context: context, title: widget.title, message: widget.explanation ?? ""),
            enabled: widget.explanation != null,
            child: PlayRow(
              children: [
                PlayText(widget.title, style: PlayTheme.font.body14.light),
                const PlaySizedBox(width: PlayPaddings.extraSmall),
                if (widget.explanation != null) PlayIcon(PlayIcons.information, size: PlaySizes.medium, color: PlayTheme.hintText()),
              ],
            ),
          ),
        ),
        if (!widget.optional)
          PlayText(
            "*${S.of(context).global_required}",
            style: PlayTheme.font.body12.light.primary,
          ),
      ],
    );
  }
}
