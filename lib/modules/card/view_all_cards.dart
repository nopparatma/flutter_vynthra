import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flutter_vynthra/app/router.dart';
import 'package:flutter_vynthra/widget/custom_app_bar.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ViewAllCardsPage extends StatefulWidget {
  const ViewAllCardsPage({super.key});

  @override
  State<ViewAllCardsPage> createState() => _ViewAllCardsPageState();
}

class _ViewAllCardsPageState extends State<ViewAllCardsPage> {
  final ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> allCards = [
    {"id": 1, "name": "พระพิฆเนศทรงหนู", "image": "https://vynthra.s3.ap-southeast-2.amazonaws.com/cards/placeholder-card.png", "meaning": "การเริ่มต้นใหม่ ความสำเร็จ"},
    {"id": 2, "name": "พระโคนนทิ", "image": "https://vynthra.s3.ap-southeast-2.amazonaws.com/cards/placeholder-card.png", "meaning": "ความรับผิดชอบ ความอดทน"},
    {"id": 3, "name": "พระแม่อุมา", "image": "https://vynthra.s3.ap-southeast-2.amazonaws.com/cards/placeholder-card.png", "meaning": "อำนาจ บารมี ความน่าเกรงขาม"},
    {"id": 4, "name": "เทพธิดาพระจันทร์", "image": "https://vynthra.s3.ap-southeast-2.amazonaws.com/cards/placeholder-card.png", "meaning": "ความงาม ความสดชื่น ความสบาย"},
    {"id": 5, "name": "พระนารายณ์บรรทมสินธุ์", "image": "https://vynthra.s3.ap-southeast-2.amazonaws.com/cards/placeholder-card.png", "meaning": "การปกป้องคุ้มครอง การพักผ่อน"},
    {"id": 6, "name": "ท้าววิรูปักษ์", "image": "https://vynthra.s3.ap-southeast-2.amazonaws.com/cards/placeholder-card.png", "meaning": "สัญชาตญาณ ไหวพริบ การเอาตัวรอด"},
    {"id": 7, "name": "พระอรุณเทพบุตร", "image": "https://vynthra.s3.ap-southeast-2.amazonaws.com/cards/placeholder-card.png", "meaning": "การเดินทาง การเริ่มต้นใหม่"},
    {"id": 8, "name": "พระทักษะ", "image": "https://vynthra.s3.ap-southeast-2.amazonaws.com/cards/placeholder-card.png", "meaning": "การเปลี่ยนแปลง การต่อสู้กับปัญหา"},
    {"id": 9, "name": "หนุมาน", "image": "https://vynthra.s3.ap-southeast-2.amazonaws.com/cards/placeholder-card.png", "meaning": "ความท้าทาย การตัดสินใจรอบคอบ"},
    {"id": 10, "name": "พญาสุครีพ", "image": "https://vynthra.s3.ap-southeast-2.amazonaws.com/cards/placeholder-card.png", "meaning": "การเริ่มต้นใหม่ ทักษะความสามารถ"},
    {"id": 11, "name": "กุมารทอง", "image": "https://vynthra.s3.ap-southeast-2.amazonaws.com/cards/placeholder-card.png", "meaning": "ความสนุก อิสระ ความดื้อรั้น"},
    {"id": 12, "name": "นางเบญจกัลยาณี", "image": "https://vynthra.s3.ap-southeast-2.amazonaws.com/cards/placeholder-card.png", "meaning": "ความอุดมสมบูรณ์ ศีลธรรม จิตใจบริสุทธิ์"},
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      title: 'ไพ่ทั้งหมด',
      isShowMenu: false,
      isShowBackAppBar: true,
      scrollController: scrollController,
      body: CustomScrollView(
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
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {});
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
                  childCount: allCards.length,
                  (BuildContext context, int index) => _buildImageWithCaption(allCards[index]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWithCaption(Map<String, dynamic> item) {
    String caption = item["name"];
    String imageUrl = item["image"];

    return InkWell(
      onTap: () => Get.toNamed(RoutePath.cardDetailPage, arguments: {'cardId': caption}),
      child: Stack(
        children: [
          Image.network(
            imageUrl,
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              color: Colors.black.withOpacity(0.5),
              child: Text(
                caption,
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
