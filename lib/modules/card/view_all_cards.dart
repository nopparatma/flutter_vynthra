import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:vynthra/app/app_controller.dart';
import 'package:vynthra/app/app_theme.dart';
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
  final FocusNode searchFocusNode = FocusNode();
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
    searchFocusNode.dispose();
    super.dispose();
  }

  void onTapCard(CardModel cardItem) {
    _clearFocus();

    if (isFromSelectCardOnly ?? false) {
      Navigator.pop(context, cardItem);
      return;
    }

    Get.toNamed(RoutePath.cardDetailPage, arguments: {'cardItem': cardItem});
  }

  void _clearFocus() {
    if (searchFocusNode.hasFocus) {
      searchFocusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _clearFocus,
      child: CommonLayout(
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
                      focusNode: searchFocusNode,
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
                                  _clearFocus();
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
                        crossAxisCount: 3,
                        childAspectRatio: 0.5,
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
      ),
    );
  }

  Widget _buildImageWithCaption(CardModel cardItem) {
    return InkWell(
      onTap: () => onTapCard(cardItem),
      child: Image.network(
        cardItem.imageUrl,
        errorBuilder: (context, error, stackTrace) {
          return Stack(
            children: [
              Container(
                color: AppTheme.primaryColor,
                child: const Center(
                  child: Icon(Icons.image_not_supported, size: 50),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      cardItem.name.th,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return CustomLoadingWidget();
        },
      ),
    );
  }
}
