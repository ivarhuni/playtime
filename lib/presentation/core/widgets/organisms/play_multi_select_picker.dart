import 'package:flutter/material.dart';
import 'package:ut_ad_leika/domain/core/extensions/common_extensions.dart';
import 'package:ut_ad_leika/infrastructure/core/platform/platform_detector.dart';
import 'package:ut_ad_leika/presentation/core/widgets/atoms/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/organisms/import.dart';

class PlayMultiSelectPicker<T> extends StatefulWidget {
  final String fieldId;
  final String title;
  final List<T> options;
  final List<T> initialSelectedOptions;
  final bool optional;
  final bool error;
  final String? errorText;
  final String? explanation;
  final void Function(List<T>) onSelectionChanged;

  const PlayMultiSelectPicker({
    super.key,
    required this.fieldId,
    required this.title,
    required this.options,
    required this.onSelectionChanged,
    this.optional = true,
    this.error = false,
    this.errorText,
    this.explanation,
    this.initialSelectedOptions = const [],
  });

  @override
  _LaMultiSelectPickerState<T> createState() => _LaMultiSelectPickerState<T>();
}

class _LaMultiSelectPickerState<T> extends State<PlayMultiSelectPicker<T>> {
  late List<T> _selectedOptions;

  @override
  void initState() {
    super.initState();
    _selectedOptions = List.from(widget.initialSelectedOptions);
  }

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (PlatformDetector.isIOS) {
      child = _buildCupertinoPillPicker();
    } else {
      child = _buildMaterialPillPicker();
    }

    return PlayFormFieldListener(
      fieldId: widget.fieldId,
      child: child,
    );
  }

  Widget _buildMaterialPillPicker() {
    return PlayCard(
      child: PlayPadding.all(
        value: PlayPaddings.medium,
        child: PlayColumn(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _getTitle(context),
            const PlaySizedBox(height: PlayPaddings.small),
            Wrap(
              spacing: PlayPaddings.small,
              runSpacing: PlayPaddings.extraSmall,
              children: widget.options.map((T option) {
                final bool isSelected = _selectedOptions.contains(option);
                return FilterChip(
                  label: PlayText(
                    option.toString(),
                    style: isSelected
                        ? PlayTheme.font.body14.onSecondary.light
                        : PlayTheme.font.body14.onSecondaryContainer.light,
                  ),
                  selected: isSelected,
                  checkmarkColor: PlayTheme.onSecondary(),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedOptions.add(option);
                      } else {
                        _selectedOptions.remove(option);
                      }
                      widget.onSelectionChanged(_selectedOptions);
                    });
                  },
                  selectedColor: PlayTheme.secondary(),
                  backgroundColor: PlayTheme.secondaryContainer(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(PlayCornerRadius.medium),
                  ),
                  side: isSelected ? BorderSide.none : const BorderSide(color: Colors.transparent),
                );
              }).toList(),
            ),
            _getError(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCupertinoPillPicker() {
    return PlayCard(
      child: PlayPadding.all(
        value: PlayPaddings.medium,
        child: PlayColumn(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _getTitle(context),
            PlayPadding(
              padding: const EdgeInsets.only(top: PlayPaddings.small),
              child: Wrap(
                spacing: PlayPaddings.small,
                runSpacing: PlayPaddings.small,
                children: widget.options.map((T option) {
                  final bool isSelected = _selectedOptions.contains(option);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedOptions.remove(option);
                        } else {
                          _selectedOptions.add(option);
                        }
                        widget.onSelectionChanged(_selectedOptions);
                      });
                    },
                    child: PlayContainer(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PlayPaddings.mediumSmall,
                        vertical: PlayPaddings.small,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? PlayTheme.secondary() : PlayTheme.secondaryContainer(),
                        borderRadius: BorderRadius.circular(PlayCornerRadius.medium),
                      ),
                      child: PlayText(
                        option.toString(),
                        style: isSelected
                            ? PlayTheme.font.body16.onSecondary.light
                            : PlayTheme.font.body16.onSecondaryContainer.light,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            _getError(context),
          ],
        ),
      ),
    );
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
                if (widget.explanation != null) const PlaySizedBox(width: PlayPaddings.extraSmall),
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

  Widget _getError(BuildContext context) {
    return PlayPadding(
      padding: const EdgeInsets.only(left: PlayPaddings.small),
      child: AnimatedCrossFade(
        duration: 300.milliseconds,
        crossFadeState: widget.error ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        firstChild: const PlaySizedBox.shrink(),
        secondChild: PlayText(
          widget.errorText ?? S.of(context).global_generic_field_error,
          style: PlayTheme.font.body14.primary,
        ),
      ),
    );
  }
}
