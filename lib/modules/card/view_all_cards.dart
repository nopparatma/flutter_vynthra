import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:vynthra/app/app_controller.dart';
import 'package:vynthra/app/router.dart';
import 'package:vynthra/models/card_model.dart';
import 'package:vynthra/utils/argument_util.dart';
import 'package:vynthra/widget/common_layout.dart';
import 'package:vynthra/widget/custom_loading.dart';
import 'package:get/get.dart';

class ViewAllCardsPage extends StatefulWidget {
  const ViewAllCardsPage({super.key});

  @override
  State<ViewAllCardsPage> createState() => _ViewAllCardsPageState();
}

class _ViewAllCardsPageState extends State<ViewAllCardsPage> {
  final AppController appController = Get.find<AppController>();
  final ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  late bool? isFromSelectCardOnly;

  @override
  void initState() {
    isFromSelectCardOnly = ArgumentUtil.getArgument<bool>('isFromSelectCardOnly');
    appController.resetFilteredCards();
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void onTapCard(CardModel cardItem) {
    if (isFromSelectCardOnly ?? false) {
      Navigator.pop(context, cardItem);
      return;
    }

    Get.toNamed(RoutePath.cardDetailPage, arguments: {'cardItem': cardItem});
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      title: (isFromSelectCardOnly ?? false) ? 'เลือกไพ่' : 'ไพ่ทั้งหมด',
      isShowMenu: false,
      isShowBackAppBar: true,
      scrollController: scrollController,
      body: Obx(() => CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverStickyHeader(
                header: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'ค้นหาไพ่...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                appController.filterCards('');
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      appController.filterCards(value);
                    },
                  ),
                ),
                sliver: SliverPadding(
                  padding: const EdgeInsets.all(8.0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      childCount: appController.filteredCards.length,
                      (BuildContext context, int index) => _buildImageWithCaption(appController.filteredCards[index]),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildImageWithCaption(CardModel cardItem) {
    return InkWell(
      onTap: () => onTapCard(cardItem),
      child: Stack(
        children: [
          Image.network(
            cardItem.imageUrl,
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
              return CustomLoadingWidget();
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              color: Colors.black.withOpacity(0.5),
              child: Text(
                cardItem.name.th,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
