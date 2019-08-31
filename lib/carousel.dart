import 'package:flutter/material.dart';

typedef Widget ItemBuilder(BuildContext context, int position);

class AmazingCarousel extends StatefulWidget {
  final int childCount;
  final int initialPage;
  final ItemBuilder itemBuilder;
  final ValueChanged<int> onSnap;

  final double childWidth;
  final double scrollingThreshold;
  final double paddingHorizontal;
  final double paddingBetweenChildren;

  factory AmazingCarousel.single({
    int childCount,
    ItemBuilder itemBuilder,
    int initialPage,
    ValueChanged<int> onSnap,
  }) {
    return AmazingCarousel._internal(
      childCount: childCount,
      itemBuilder: itemBuilder,
      initialPage: initialPage,
      onSnap: onSnap,
    );
  }

  factory AmazingCarousel.createCarousel({
    int childCount,
    ItemBuilder itemBuilder,
    int initialPage = 0,
    double childWidth,
    double scrollingThreshold = 0.3,
    double paddingHorizontal,
    double paddingBetweenChildren,
    ValueChanged<int> onSnap,
  }) {
    return AmazingCarousel._internal(
      childCount: childCount,
      itemBuilder: itemBuilder,
      initialPage: initialPage,
      childWidth: childWidth,
      scrollingThreshold: scrollingThreshold,
      paddingHorizontal: paddingHorizontal,
      paddingBetweenChildren: paddingBetweenChildren,
      onSnap: onSnap,
    );
  }

  factory AmazingCarousel.multiple({
    int childCount,
    ItemBuilder itemBuilder,
    int initialPage = 0,
    double childWidth,
    double scrollingThreshold = 0.3,
    double paddingHorizontal,
    double paddingBetweenChildren,
    ValueChanged<int> onSnap,
  }) {
    return AmazingCarousel._internal(
      childCount: childCount,
      itemBuilder: itemBuilder,
      initialPage: initialPage,
      childWidth: childWidth,
      scrollingThreshold: scrollingThreshold,
      paddingHorizontal: paddingHorizontal,
      paddingBetweenChildren: paddingBetweenChildren,
      onSnap: onSnap,
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
    this.onSnap,
  });

  @override
  _AmazingCarouselState createState() => _AmazingCarouselState();
}

class _AmazingCarouselState extends State<AmazingCarousel> {
  int _page = 0;
  double _currentScrollingOffset = 0.0;
  double _startDx = 0.0;
  double _endDx = 0.0;

  ScrollController _controller;

  @override
  void initState() {
    super.initState();

    if (widget.initialPage != 0) {
      _initializeScrollControllerWithInitialValues();
    }

    if (widget.initialPage == 0) {
      _initializeScrollControllerWithoutInitialValues();
    }
  }

  void _initializeScrollControllerWithInitialValues() {
    double initialPageOffet = _getScrollingOffsetByChildPosition(
      widget.initialPage,
    );
    _saveCurrentScrollingValues(
      initialPageOffet,
      widget.initialPage,
    );
    _controller = ScrollController(
      initialScrollOffset: initialPageOffet,
    );
  }

  void _initializeScrollControllerWithoutInitialValues() {
    _controller = ScrollController();
  }

  bool _isScrollingRightward() => this._endDx < this._startDx;
  bool _isScrollingLeftward() => this._endDx > this._startDx;

  bool _isScrollingBackward(delta) => delta > 0;

  double getMaximumWidth() => (widget.childCount * widget.childWidth +
      (widget.childCount - 1 > 0 ? widget.childCount - 1 : 0) *
          widget.paddingBetweenChildren);

  double getScrolledWidth() => ((this._page + 1) * widget.childWidth +
      (this._page) * widget.paddingBetweenChildren);

  bool _isTryingToScrollToTheEnd(delta) {
    if (_isScrollingBackward(delta)) {
      return false;
    }

    final maxWidth = getMaximumWidth();
    final scrolledWidth = getScrolledWidth();
    return scrolledWidth >= maxWidth;
  }

  bool _isScrolling(delta) => delta != 0;

  void _onHorizontalDragEnd(DragEndDetails details) {
    var maybeNextPage = this._page;
    if (_isScrollingLeftward()) {
      maybeNextPage--;
    }

    if (_isScrollingRightward()) {
      maybeNextPage++;
    }

    if (maybeNextPage < 0) {
      maybeNextPage = 0;
    }

    if (maybeNextPage >= widget.childCount) {
      maybeNextPage = widget.childCount - 1;
    }

    final nextScrollingOffset =
        _getScrollingOffsetByChildPosition(maybeNextPage);

    _animateToOffset(nextScrollingOffset);
    _saveCurrentScrollingValues(nextScrollingOffset, maybeNextPage);
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_isTryingToScrollToTheEnd(details.primaryDelta) &&
        _currentScrollingOffset > details.primaryDelta &&
        _isScrolling(details.primaryDelta)) {
      setState(() {
        _currentScrollingOffset -= details.primaryDelta;
      });
      _controller.jumpTo(_currentScrollingOffset);
    }

    _endDx = details.localPosition.dx;
  }

  double _getScrollingOffsetByChildPosition(int position) {
    if (position < widget.childCount - 1) {
      return position *
          (widget.childWidth +
              widget.paddingHorizontal -
              widget.paddingBetweenChildren);
    }

    if (position == widget.childCount - 1) {
      return getMaximumWidth() -
          (MediaQuery.of(context).size.width - widget.paddingHorizontal * 2);
    }

    throw Exception("Position is out of range");
  }

  void executeOnSnapIfAvailable() {
    if (widget.onSnap != null) {
      widget.onSnap(this._page);
    }
  }

  void _animateToOffset(double offset) {
    _controller
        .animateTo(
      offset,
      curve: Curves.linearToEaseOut,
      duration: const Duration(milliseconds: 500),
    )
        .then(
      (_) {
        executeOnSnapIfAvailable();
      },
    );
  }

  void _saveCurrentScrollingValues(double offset, int nextPage) {
    this._currentScrollingOffset = offset;
    this._page = nextPage;
  }

  void _onHorizontalDragStart(DragStartDetails start) {
    _startDx = start.localPosition.dx;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragStart: _onHorizontalDragStart,
      child: Container(
        width: widget.paddingHorizontal * 2 + getMaximumWidth(),
        child: CustomScrollView(
          shrinkWrap: true,
          controller: _controller,
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          slivers: <Widget>[
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.paddingHorizontal,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  widget.itemBuilder,
                  childCount: widget.childCount,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
