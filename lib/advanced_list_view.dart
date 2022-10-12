import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AdvancedListView<T> extends StatefulWidget {
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final bool hasMoreData;
  final Function()? onLoadMoreData;
  final List<T> items;
  final bool shrinkWrap;
  final Key? listKey;
  final String emptyText;
  final String retryMessage;
  final ButtonStyle? retryButtonStyle;
  final Color indicatorColor;
  final TextStyle? retryMessageTextStyle;
  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;
  final bool canRefresh;
  final bool showEmptyWidget;
  bool showErrorWidget;
  bool showLoadingWidget;
  final Future<void> Function()? onRefresh;

  AdvancedListView({
    required this.items,
    required this.itemBuilder,
    this.showLoadingWidget = true,
    this.retryMessageTextStyle,
    this.indicatorColor = Colors.blueAccent,
    this.showErrorWidget = false,
    this.retryButtonStyle,
    this.retryMessage = 'try again',
    this.emptyText = 'nothing to show',
    this.showEmptyWidget = false,
    this.hasMoreData = false,
    this.shrinkWrap = false,
    this.listKey,
    this.onLoadMoreData,
    this.canRefresh = false,
    this.onRefresh,
    this.padding,
    this.scrollDirection = Axis.vertical,
    final super.key,
  }) : assert(
          canRefresh || onRefresh == null,
          'onRefresh can not be null because of canRefresh is true',
        );

  @override
  State<AdvancedListView<T>> createState() => _AdvancedListViewState<T>();
}

class _AdvancedListViewState<T> extends State<AdvancedListView<T>> {
  final ScrollController _scrollController = ScrollController();

  bool _handleScrollNotification(final ScrollNotification notification) {
    if (notification is ScrollEndNotification &&
        widget.scrollDirection == Axis.vertical) {

      if (notification.metrics.maxScrollExtent == _scrollController.offset) {
        if (widget.hasMoreData) {
          setState(() {
            widget.showLoadingWidget = true;
          });
          widget.onLoadMoreData?.call();
        }
      }
    }
    return false;
  }

  @override
  Widget build(final BuildContext context) => widget.showErrorWidget
      ? _refreshWidget()
      : widget.showEmptyWidget
          ? _emptyListWidget()
          : (widget.showLoadingWidget && widget.items.isEmpty)
              ? _listLoading()
              : RefreshIndicator(
                  onRefresh: widget.onRefresh ??
                      () async => print(' do something async'),
                  notificationPredicate: (widget.canRefresh &&
                          widget.scrollDirection == Axis.vertical)
                      ? (final _) => true
                      : (final _) => false,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: _handleScrollNotification,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (final context, final index) {
                        if (index < widget.items.length) {
                          return widget.itemBuilder(
                            context,
                            index,
                            widget.items[index],
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.all(8),
                            child: Center(
                              child: widget.showLoadingWidget
                                  ? CircularProgressIndicator(
                                      color: widget.indicatorColor,
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          );
                        }
                      },
                      key: widget.listKey,
                      controller: _scrollController,
                      shrinkWrap: widget.shrinkWrap,
                      itemCount: widget.items.length + 1,
                      scrollDirection: widget.scrollDirection,
                      padding: widget.padding,
                    ),
                  ),
                );

  Widget _refreshWidget() => Center(
        child: OutlinedButton(
          onPressed: _onRefreshButton,
          style: widget.retryButtonStyle,
          child: Text(
            widget.retryMessage,
            style: widget.retryMessageTextStyle,
          ),
        ),
      );

  void _onRefreshButton() {
    widget.items.clear();
    setState(() {
      widget.showErrorWidget = false;
      widget.showLoadingWidget = true;
    });
    widget.onRefresh?.call();
  }

  Widget _listLoading() => const Center(
        child: CircularProgressIndicator(),
      );

  Widget _emptyListWidget() => RefreshIndicator(
        onRefresh: widget.onRefresh ?? () async => print(' do something async'),
        notificationPredicate:
            widget.canRefresh ? (final _) => true : (final _) => false,
        child: Stack(
          children: <Widget>[ListView(), Center(child: Text(widget.emptyText))],
        ),
      );
}
