import 'package:flutter/material.dart';
import 'package:flutter_vynthra/models/card_model.dart';
import 'package:flutter_vynthra/utils/argument_util.dart';
import 'package:flutter_vynthra/widget/custom_app_bar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CardDetailPage extends StatefulWidget {
  const CardDetailPage({super.key});

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  final ScrollController scrollController = ScrollController();
  late CardModel? cardItem;

  @override
  void initState() {
    cardItem = ArgumentUtil.getArgument<CardModel>('cardItem');

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
        title: cardItem?.name.th ?? "",
        isShowMenu: false,
        isShowBackAppBar: true,
        scrollController: scrollController,
        body: ListView(
          controller: scrollController,
          children: [
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
            // Card title and meaning
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The Fool (0)',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(label: Text('Major Arcana')),
                      SizedBox(width: 8),
                      Chip(label: Text('Air Element')),
                    ],
                  ),
                ],
              ),
            ),

            // Card description
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ความหมายทั่วไป',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ไพ่ The Fool แทนการเริ่มต้นใหม่ การผจญภัย ความไร้เดียงสา และความเป็นไปได้ไม่สิ้นสุด ไพ่นี้เชิญชวนให้เราเปิดใจกว้าง กระโดดลงไปในความไม่แน่นอน และเชื่อมั่นในการเดินทางของชีวิต',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'ความหมายเมื่อไพ่ตั้งตรง',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'การเริ่มต้นใหม่ อิสรภาพ ความคิดสร้างสรรค์ การมองโลกในแง่ดี โอกาสใหม่ การก้าวออกจากความสบายใจ',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'ความหมายเมื่อไพ่กลับหัว',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ความประมาท การตัดสินใจที่ไม่ดี ความเสี่ยงที่ไม่จำเป็น ความเปราะบาง การขาดความเชื่อในตัวเอง',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            // Diviner's section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'สัญลักษณ์สำคัญ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSymbolItem(Icons.hiking, 'การเดินทาง'),
                      _buildSymbolItem(Icons.brightness_5, 'ดวงอาทิตย์'),
                      _buildSymbolItem(Icons.pets, 'สุนัข (ความภักดี)'),
                    ],
                  ),
                ],
              ),
            ),

            // Related cards section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ไพ่ที่เกี่ยวข้อง',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        List<String> relatedCards = ['The Magician', 'The Sun', 'The World', 'The Sun', 'The Sun'];
                        List<String> relatedUrls = [
                          'https://vynthra.s3.ap-southeast-2.amazonaws.com/cards/placeholder-card.png',
                          'https://vynthra.s3.ap-southeast-2.amazonaws.com/cards/placeholder-card.png',
                          'https://vynthra.s3.ap-southeast-2.amazonaws.com/cards/placeholder-card.png',
                          'https://vynthra.s3.ap-southeast-2.amazonaws.com/cards/placeholder-card.png',
                          'https://vynthra.s3.ap-southeast-2.amazonaws.com/cards/placeholder-card.png',
                        ];

                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  relatedUrls[index],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(relatedCards[index]),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  // Helper method for building symbol items
  Widget _buildSymbolItem(IconData icon, String meaning) {
    return Column(
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 4),
        Text(
          meaning,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
