import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_vynthra/app/router.dart';
import 'package:get/get.dart';

class CommonLayout extends StatefulWidget {
  final String title;
  final Widget body;
  final bool isShowMenu;
  final bool isShowBackAppBar;
  final ScrollController scrollController;

  const CommonLayout({
    super.key,
    required this.title,
    required this.body,
    required this.scrollController,
    this.isShowMenu = true,
    this.isShowBackAppBar = false,
  });

  @override
  createState() => _CommonLayoutState();
}

class _CommonLayoutState extends State<CommonLayout> {
  final double _appBarMinHeight = 0;
  final double _appBarMaxHeight = kToolbarHeight;
  double _appBarHeight = kToolbarHeight;
  bool _showTitle = true;
  final _key = GlobalKey<ExpandableFabState>();

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_scrollListener);
    widget.scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (widget.scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_appBarHeight > _appBarMinHeight) {
        setState(() {
          _appBarHeight = (_appBarHeight - 2).clamp(_appBarMinHeight, _appBarMaxHeight);
          _showTitle = false;
        });
      }
    }

    if (widget.scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (_appBarHeight < _appBarMaxHeight) {
        setState(() {
          _appBarHeight = (_appBarHeight + 2).clamp(_appBarMinHeight, _appBarMaxHeight);
          _showTitle = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(_appBarHeight),
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          flexibleSpace: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _appBarHeight,
          ),
          title: AnimatedOpacity(
            opacity: _showTitle ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(widget.title),
          ),
          leading: Visibility(
            visible: widget.isShowBackAppBar && _showTitle,
            child: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                Icons.keyboard_arrow_left,
                size: 40,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(child: widget.body),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: !widget.isShowMenu
          ? null
          : ExpandableFab(
              key: _key,
              type: ExpandableFabType.up,
              childrenAnimation: ExpandableFabAnimation.none,
              distance: 70,
              overlayStyle: ExpandableFabOverlayStyle(
                color: Colors.white.withOpacity(0.9),
                blur: 2,
              ),
              openCloseStackAlignment: Alignment.centerLeft,
              children: [
                Row(
                  children: [
                    const Text('ความหมายไพ่'),
                    const SizedBox(width: 20),
                    FloatingActionButton.large(
                      child: const Icon(Icons.card_giftcard),
                      onPressed: () {
                        _key.currentState?.toggle();
                        Get.toNamed(RoutePath.viewAllCardsPage);
                      },
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
