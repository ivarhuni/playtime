import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ut_ad_leika/infrastructure/core/platform/platform_detector.dart';
import 'package:ut_ad_leika/presentation/core/widgets/atoms/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/molecules/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/organisms/import.dart';

class PlayDatePicker extends StatefulWidget {
  final String fieldId;
  final String title;
  final String? hint;
  final DateTime? defaultDate;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool optional;
  final String? explanation;
  final void Function(DateTime selectedDate) onDateSelected;

  const PlayDatePicker({
    super.key,
    required this.fieldId,
    required this.title,
    required this.onDateSelected,
    this.hint,
    this.defaultDate,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.optional = true,
    this.explanation,
  });

  @override
  _LaDatePickerState createState() => _LaDatePickerState();
}

class _LaDatePickerState extends State<PlayDatePicker> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return PlayCard(
      child: Padding(
        padding: const EdgeInsets.all(PlayPaddings.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: PlayPaddings.small,
          children: [
            Row(
              children: [
                Expanded(
                  child: PlayTapVisual(
                    onTap: () => PlayConfirmationDialog.show(
                      context: context,
                      title: widget.title,
                      message: widget.explanation ?? "",
                    ),
                    enabled: widget.explanation != null,
                    child: Row(
                      spacing: PlayPaddings.extraSmall,
                      children: [
                        PlayText(widget.title, style: PlayTheme.font.body14.light),
                        if (widget.explanation != null) Icon(PlayIcons.information, size: PlaySizes.medium, color: PlayTheme.hintText()),
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
            ),
            PlayTapVisual(
              onTap: () {
                if (PlatformDetector.isIOS) {
                  _showCupertinoDatePicker(context);
                } else {
                  _showMaterialDatePicker(context);
                }
              },
              child: PlayTextField(
                fieldId: widget.fieldId,
                enabled: false,
                showCard: false,
                actionIcon: PlayIcons.calendar,
                hintColor: _selectedDate == null ? PlayTheme.hintText() : PlayTheme.onSecondaryContainer(),
                hint: _selectedDate != null ? DateFormat.yMMMMd().format(_selectedDate!) : widget.hint ?? "",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMaterialDatePicker(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.initialDate ?? widget.defaultDate ?? DateTime(DateTime.now().year),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        // Customizing the Material date picker
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              surface: PlayTheme.surface(),
              primary: PlayTheme.primary(),
              onPrimary: PlayTheme.onPrimary(),
              onSurface: PlayTheme.onSurface(),
            ),
            //textButtonTheme: TextButtonThemeData(
            //  style: PlayTheme.font.body16.primary,
            //),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
      widget.onDateSelected(pickedDate);
    }
  }

  Future<void> _showCupertinoDatePicker(BuildContext context) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: PlaySizes.pickerHeight,
        decoration: BoxDecoration(
          color: PlayTheme.surface(),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              height: PlaySizes.pickerHeaderHeight,
              decoration: BoxDecoration(
                color: PlayTheme.surface(),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    child: PlayText(
                      S.of(context).global_done,
                      style: PlayTheme.font.body16.primary,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      if (_selectedDate != null) {
                        widget.onDateSelected(_selectedDate!);
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                initialDateTime: widget.initialDate ?? widget.defaultDate ?? DateTime(DateTime.now().year),
                minimumDate: widget.firstDate,
                maximumDate: widget.lastDate,
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (DateTime date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (_selectedDate == null) {
      setState(() {
        _selectedDate = widget.initialDate ?? widget.defaultDate ?? DateTime(DateTime.now().year);
        widget.onDateSelected(_selectedDate!);
      });
    }
  }
}
