import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:vynthra/app/app_theme.dart';
import 'package:vynthra/models/card_model.dart';
import 'package:vynthra/utils/argument_util.dart';
import 'package:vynthra/utils/color_util.dart';
import 'package:vynthra/widget/common_layout.dart';
import 'package:vynthra/widget/custom_loading.dart';

class CardDetailPage extends StatefulWidget {
  const CardDetailPage({super.key});

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> with SingleTickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  late CardModel? cardItem;
  late TabController _tabController;

  @override
  void initState() {
    cardItem = ArgumentUtil.getArgument<CardModel>('cardItem');
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
        title: cardItem?.name.th ?? "",
        isShowMenu: false,
        isShowBackAppBar: true,
        scrollController: scrollController,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.network(
                        cardItem?.imageUrl ?? "",
                        fit: BoxFit.fitHeight,
                        height: 300,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            height: 300,
                            child: const Center(
                              child: Icon(Icons.image_not_supported, size: 50),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return CustomLoadingWidget();
                        },
                      ),
                    ),
                    SizedBox(height: 8),
                    Chip(
                        label: Text(
                      cardItem?.cardSet.th ?? "",
                      style: Theme.of(context).textTheme.titleMedium,
                    )),
                    SizedBox(height: 8),
                  ],
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'รายละเอียด'),
                      Tab(text: 'การพยากรณ์'),
                    ],
                    labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    indicatorColor: AppTheme.accentColor,
                    labelColor: AppTheme.accentColor,
                    indicatorSize: TabBarIndicatorSize.tab,
                    unselectedLabelColor: Colors.grey,
                    dividerColor: AppTheme.dividerColor,
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildTabContent(
                cardItem?.description ?? [],
              ),
              _buildTabContent(
                cardItem?.prediction ?? [],
              ),
            ],
          ),
        ));
  }

  Widget _buildTabContent(List<Description> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildDescriptionItem(items[index]);
      },
    );
  }

  Widget _buildDescriptionItem(Description item) {
    return ExpandableNotifier(
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: hexToColor(item.colorCode),
                  shape: BoxShape.rectangle,
                ),
              ),
            ),
            ScrollOnExpand(
              scrollOnExpand: true,
              scrollOnCollapse: false,
              child: ExpandablePanel(
                theme: ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  tapBodyToCollapse: true,
                  tapBodyToExpand: true,
                  iconColor: AppTheme.iconColorPrimary,
                ),
                header: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      item.category.th,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    )),
                collapsed: SelectionArea(
                  child: Text(
                    item.content.th,
                    style: Theme.of(context).textTheme.bodyLarge,
                    softWrap: true,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                expanded: SelectionArea(
                  child: Text(
                    item.content.th,
                    style: Theme.of(context).textTheme.bodyLarge,
                    softWrap: true,
                  ),
                ),
                builder: (_, collapsed, expanded) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: Expandable(
                      collapsed: collapsed,
                      expanded: expanded,
                      theme: const ExpandableThemeData(crossFadePoint: 0),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
