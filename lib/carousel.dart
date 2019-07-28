import 'package:flutter/material.dart';

typedef Widget ItemBuilder(BuildContext context, int position);

class AmazingCarousel extends StatefulWidget {
  final int childCount;
  final int initialPage;
  final ItemBuilder itemBuilder;

  final double childWidth;
  final double scrollingThreshold;
  final double paddingHorizontal;
  final double paddingBetweenChildren;

  factory AmazingCarousel.single({
    int childCount,
    ItemBuilder itemBuilder,
    int initialPage,
  }) {
    return AmazingCarousel._internal(
      childCount: childCount,
      itemBuilder: itemBuilder,
      initialPage: initialPage,
    );
  }

  factory AmazingCarousel.multiple({
    int childCount,
    ItemBuilder itemBuilder,
    int initialPage,
    double childWidth,
    double scrollingThreshold = 0.3,
    double paddingHorizontal,
    double paddingBetweenChildren,
  }) {
    return AmazingCarousel._internal(
      childCount: childCount,
      itemBuilder: itemBuilder,
      initialPage: initialPage,
      childWidth: childWidth,
      scrollingThreshold: scrollingThreshold,
      paddingHorizontal: paddingHorizontal,
      paddingBetweenChildren: paddingBetweenChildren,
    );
  }

  AmazingCarousel._internal({
    this.childCount,
    this.initialPage,
    this.itemBuilder,
    this.childWidth,
    this.scrollingThreshold,
    this.paddingHorizontal,
    this.paddingBetweenChildren,
  });

  @override
  _AmazingCarouselState createState() => _AmazingCarouselState();
}

class _AmazingCarouselState extends State<AmazingCarousel> {
  int _page = 0;
  double _currentScrollingOffset = 0.0;

  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  bool _isScrollingRightward() =>
      this._currentScrollingOffset > this._page * widget.childWidth &&
      this._currentScrollingOffset - this._page * widget.childWidth >
          widget.childWidth * widget.scrollingThreshold;
  bool _isScrollingLeftward() =>
      this._page * widget.childWidth > this._currentScrollingOffset &&
      this._page * widget.childWidth - this._currentScrollingOffset >
          widget.childWidth * widget.scrollingThreshold;

  void _onHorizontalDragEnd(DragEndDetails details) {
    var maybeNextPage = this._page;
    if (_isScrollingLeftward()) {
      maybeNextPage--;
    }

    if (_isScrollingRightward()) {
      maybeNextPage++;
    }

    final nextScrollingOffset =
        _getScrollingOffsetByChildPosition(maybeNextPage);

    _animateToOffset(nextScrollingOffset);
    _saveCurrentScrollingValues(nextScrollingOffset, maybeNextPage);
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_currentScrollingOffset > details.primaryDelta &&
        (_currentScrollingOffset - details.primaryDelta) !=
            _currentScrollingOffset) {
      _currentScrollingOffset = _currentScrollingOffset - details.primaryDelta;
      _controller.jumpTo(
        _currentScrollingOffset,
      );
    }
  }

  double _getScrollingOffsetByChildPosition(int position) {
    if (position == 1) {
      return widget.childWidth + widget.paddingHorizontal;
    }

    return position * (widget.childWidth + widget.paddingBetweenChildren * 2);
  }

  void _animateToOffset(double offset) {
    _controller.animateTo(
      offset,
      curve: Curves.elasticOut,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _saveCurrentScrollingValues(double offset, int nextPage) {
    this._currentScrollingOffset = offset;
    this._page = nextPage;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      child: CustomScrollView(
          shrinkWrap: true,
          controller: _controller,
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildBuilderDelegate(widget.itemBuilder),
            )
          ],
        ),
    );
  }
}