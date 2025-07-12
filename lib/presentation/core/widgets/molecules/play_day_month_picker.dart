import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ut_ad_leika/infrastructure/core/platform/platform_detector.dart';
import 'package:ut_ad_leika/presentation/core/widgets/atoms/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/molecules/import.dart';

class PlayDayMonthPicker extends StatefulWidget {
  final String fieldId;
  final String title;
  final String? hint;
  final int? initialMonth;
  final int? initialDay;
  final bool optional;
  final void Function(int month, int day) onDateSelected;

  const PlayDayMonthPicker({
    super.key,
    required this.fieldId,
    required this.title,
    required this.onDateSelected,
    this.hint,
    this.initialMonth,
    this.initialDay,
    this.optional = true,
  });

  @override
  _LaDayMonthPickerState createState() => _LaDayMonthPickerState();
}

class _LaDayMonthPickerState extends State<PlayDayMonthPicker> {
  int? _selectedMonth;
  int? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialMonth;
    _selectedDay = widget.initialDay;
  }

  @override
  Widget build(BuildContext context) {
    return PlayCard(
      child: PlayPadding.all(
        value: PlayPaddings.medium,
        child: PlayColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlayRow(
              children: [
                PlayExpanded(child: PlayText(widget.title, style: PlayTheme.font.body14.light)),
                if (!widget.optional)
                  PlayText("*${S.of(context).global_required}", style: PlayTheme.font.body12.light.primary),
              ],
            ),
            const PlaySizedBox(height: PlayPaddings.small),
            PlayTapVisual(
              onTap: () {
                if (PlatformDetector.isIOS) {
                  _showCupertinoDayMonthPicker(context);
                } else {
                  _showMaterialDayMonthPicker(context);
                }
              },
              child: PlayTextField(
                fieldId: widget.fieldId,
                enabled: false,
                showCard: false,
                actionIcon: PlayIcons.calendarDayMonth,
                hintColor: _selectedDay == null ? PlayTheme.hintText() : PlayTheme.onSecondaryContainer(),
                hint: _selectedDay != null ? _getSelectedDateText(context) : widget.hint ?? "",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCupertinoDayMonthPicker(BuildContext context) async {
    int tempMonth = _selectedMonth ?? 1;
    int tempDay = _selectedDay ?? 1;

    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return PlayContainer(
          height: PlaySizes.pickerHeight,
          decoration: const BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(PlayCornerRadius.large)),
          ),
          child: PlayColumn(
            children: [
              // Done button
              PlayContainer(
                height: PlaySizes.pickerHeaderHeight,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: PlayPaddings.medium),
                child: CupertinoButton(
                  onPressed: () {
                    setState(() {
                      _selectedMonth = tempMonth;
                      _selectedDay = tempDay;
                    });
                    widget.onDateSelected(_selectedMonth!, _selectedDay!);
                    Navigator.pop(context);
                  },
                  child: const PlayText("Done", style: TextStyle(color: CupertinoColors.activeBlue)),
                ),
              ),
              // Day-Month Picker
              PlayExpanded(
                child: PlayRow(
                  children: [
                    // Month Picker
                    PlayExpanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: tempMonth - 1),
                        itemExtent: PlaySizes.pickerItemExtent,
                        onSelectedItemChanged: (index) {
                          tempMonth = index + 1;
                        },
                        children: List.generate(
                          12,
                          (int index) => PlayCenter(child: PlayText(_getMonthName(index + 1), style: PlayTheme.font.body14)),
                        ),
                      ),
                    ),
                    // Day Picker
                    PlayExpanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: tempDay - 1),
                        itemExtent: PlaySizes.pickerItemExtent,
                        onSelectedItemChanged: (int index) {
                          tempDay = index + 1;
                        },
                        children: List.generate(
                          31,
                          (index) => PlayCenter(child: PlayText("${index + 1}", style: PlayTheme.font.body14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getMonthName(int month) {
    return DateFormat.MMMM().format(DateTime(0, month));
  }

  Future<void> _showMaterialDayMonthPicker(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: PlayCornerRadius().dialog,
          child: PlayPadding.all(
            value: PlayPaddings.medium,
            child: PlayColumn(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                PlayText(widget.title, style: PlayTheme.font.body18.bold),
                const PlaySizedBox(height: PlayPaddings.medium),

                // Month Dropdown
                DropdownButton<int>(
                  value: _selectedMonth,
                  isExpanded: true,
                  items: List.generate(12, (int index) {
                    return DropdownMenuItem<int>(
                      value: index + 1,
                      child: PlayText(_getMonthName(index + 1), style: PlayTheme.font.body14),
                    );
                  }),
                  onChanged: (int? value) {
                    setState(() {
                      _selectedMonth = value;
                      _selectedDay = null;
                    });
                  },
                ),
                const PlaySizedBox(height: PlayPaddings.medium),

                // Day Grid
                _buildDayGrid(),

                // Confirm Button
                const PlaySizedBox(height: PlayPaddings.medium),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedDay != null) {
                      widget.onDateSelected(_selectedMonth ?? 1, _selectedDay!);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: PlayText(S.of(context).global_pick_date, style: PlayTheme.font.body14)),
                      );
                    }
                  },
                  child: PlayText(S.of(context).global_confirm, style: PlayTheme.font.body14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayGrid() {
    final int daysInMonth = _getDaysInMonth(_selectedMonth ?? 1);

    return GridView.builder(
      shrinkWrap: true,
      itemCount: daysInMonth,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, // 7 days in a week
        crossAxisSpacing: PlayPaddings.small,
        mainAxisSpacing: PlayPaddings.small,
      ),
      itemBuilder: (BuildContext context, int index) {
        final int day = index + 1;
        final bool isSelected = day == _selectedDay;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDay = day;
            });
          },
          child: PlayContainer(
            decoration: BoxDecoration(
              color: isSelected ? PlayTheme.primary() : PlayTheme.secondaryContainer(),
              borderRadius: BorderRadius.circular(PlayCornerRadius.small),
            ),
            child: PlayCenter(
              child: PlayText(
                _getMonthName(index + 1),
                style: TextStyle(
                  color: isSelected ? PlayTheme.onPrimary() : PlayTheme.onSecondaryContainer(),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  int _getDaysInMonth(int month) {
    return DateTime(2000, month + 1, 0).day;
  }

  String _getSelectedDateText(BuildContext context) {
    final DateFormat format = DateFormat(S.of(context).date_format_month_and_day);
    return format.format(DateTime(2000, _selectedMonth ?? 1, _selectedDay ?? 1));
  }
}
