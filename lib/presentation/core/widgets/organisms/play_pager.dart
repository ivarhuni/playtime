import 'package:flutter/material.dart';
import 'package:ut_ad_leika/presentation/core/theme/play_theme.dart';
import 'package:ut_ad_leika/presentation/core/widgets/atoms/import.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PlayPager extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final void Function(int index)? onDotClicked;
  final PageController? controller;
  final ScrollPhysics? physics;

  const PlayPager({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.onDotClicked,
    this.controller,
    this.physics,
  });

  @override
  State<StatefulWidget> createState() {
    return _LaPagerState();
  }
}

class _LaPagerState extends State<PlayPager> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();

    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlayColumn(
      children: [
        PlayExpanded(
          child: PageView.builder(
            controller: widget.controller ?? _controller,
            itemCount: widget.itemCount,
            itemBuilder: widget.itemBuilder,
            physics: widget.physics,
          ),
        ),
        const PlaySizedBox(height: PlayPaddings.medium),
        SmoothPageIndicator(
          controller: widget.controller ?? _controller,
          count: widget.itemCount,
          effect: SwapEffect(
            type: SwapType.yRotation,
            activeDotColor: PlayTheme.primary(),
            dotColor: PlayTheme.singleElement(),
          ),
          onDotClicked: widget.onDotClicked,
        ),
      ],
    );
  }
}
