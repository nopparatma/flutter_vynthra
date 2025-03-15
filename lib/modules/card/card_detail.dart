import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vynthra/models/card_model.dart';
import 'package:flutter_vynthra/utils/argument_util.dart';
import 'package:flutter_vynthra/utils/color_util.dart';
import 'package:flutter_vynthra/widget/custom_app_bar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
                    // Card image
                    Center(
                      child: Image.network(
                        'https://vynthra.s3.ap-southeast-2.amazonaws.com/cards/placeholder-card.png',
                        height: 300,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image_not_supported, size: 50),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: LoadingAnimationWidget.discreteCircle(
                              color: Colors.deepPurpleAccent,
                              size: 25,
                            ),
                          );
                        },
                      ),
                    ),

                    // Card title and chip
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Chip(
                            label: Text(cardItem?.cardSet.th ?? ""),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'รายละเอียด'),
                      Tab(text: 'การพยากรณ์และคำทำนาย'),
                    ],
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    indicatorColor: Colors.deepPurpleAccent,
                    labelColor: Colors.deepPurpleAccent,
                    unselectedLabelColor: Colors.grey,
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              // First Tab - รายละเอียด (Details)
              _buildTabContent(
                cardItem?.description ?? [],
              ),

              // Second Tab - การพยากรณ์และคำทำนาย (Prediction)
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
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  tapBodyToCollapse: true,
                ),
                header: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      item.category.th,
                      style: Theme.of(context).textTheme.titleLarge,
                    )),
                collapsed: Text(
                  item.content.th,
                  style: Theme.of(context).textTheme.bodyMedium,
                  softWrap: true,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
                expanded: Text(
                  item.content.th,
                  style: Theme.of(context).textTheme.bodyMedium,
                  softWrap: true,
                  overflow: TextOverflow.fade,
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

// SliverPersistentHeaderDelegate for pinned tab bar
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
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
