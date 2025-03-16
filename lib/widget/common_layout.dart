import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:vynthra/app/app_theme.dart';
import 'package:vynthra/app/router.dart';
import 'package:get/get.dart';

class CommonLayout extends StatefulWidget {
  final String title;
  final Widget body;
  final bool isShowMenu;
  final bool isShowBackAppBar;
  final ScrollController scrollController;
  final Widget? action;

  const CommonLayout({
    super.key,
    required this.title,
    required this.body,
    required this.scrollController,
    this.isShowMenu = true,
    this.isShowBackAppBar = false,
    this.action,
  });

  @override
  createState() => _CommonLayoutState();
}

class _CommonLayoutState extends State<CommonLayout> with SingleTickerProviderStateMixin {
  final double _appBarMaxHeight = kToolbarHeight;
  double _appBarHeight = kToolbarHeight;
  bool _showTitle = true;
  final _key = GlobalKey<ExpandableFabState>();
  late AnimationController _animationController;
  ScrollDirection _lastScrollDirection = ScrollDirection.idle;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    // สร้าง AnimationController เพื่อควบคุมการเคลื่อนไหวของ AppBar
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150), // ลดเวลาลงเพื่อให้เร็วขึ้น
    )..addListener(() {
        setState(() {
          _appBarHeight = _animationController.value * _appBarMaxHeight;
          _showTitle = _animationController.value > 0.5;
        });
      });

    // เริ่มต้นการแสดง AppBar
    _animationController.value = 1.0;

    widget.scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_scrollListener);
    _animationController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // ถ้ากำลังอนิเมชั่นอยู่ และทิศทางไม่เปลี่ยน ไม่ต้องทำอะไร
    if (_isAnimating && widget.scrollController.position.userScrollDirection == _lastScrollDirection) {
      return;
    }

    _lastScrollDirection = widget.scrollController.position.userScrollDirection;

    // ถ้าเลื่อนลง (reverse) ให้ซ่อน AppBar
    if (_lastScrollDirection == ScrollDirection.reverse) {
      _isAnimating = true;
      _animationController.animateTo(0.0).then((_) {
        // เมื่อแอนิเมชั่นเสร็จ ยกเลิกสถานะกำลังแอนิเมท
        _isAnimating = false;
      });
    }
    // ถ้าเลื่อนขึ้น (forward) ให้แสดง AppBar
    else if (_lastScrollDirection == ScrollDirection.forward) {
      _isAnimating = true;
      _animationController.animateTo(1.0).then((_) {
        // เมื่อแอนิเมชั่นเสร็จ ยกเลิกสถานะกำลังแอนิเมท
        _isAnimating = false;
      });
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
            duration: const Duration(milliseconds: 150),
            height: _appBarHeight,
          ),
          centerTitle: true,
          title: AnimatedOpacity(
            opacity: _showTitle ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
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
          actions: widget.action == null
              ? null
              : [
                  Visibility(
                    visible: _showTitle,
                    child: widget.action ?? Container(),
                  )
                ],
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
                color: AppTheme.dialogBackgroundColor.withOpacity(0.9),
                blur: 5,
              ),
              openCloseStackAlignment: Alignment.centerLeft,
              children: [
                Row(
                  children: [
                    Text(
                      'ไพ่ทั้งหมด',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
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
