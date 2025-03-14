import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vynthra/app/router.dart';
import 'package:flutter_vynthra/utils/color_util.dart';
import 'package:flutter_vynthra/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController scrollController = ScrollController();

  final List<Map<String, dynamic>> cardPositions = [
    {"id": 1, "name": "วาสนา", "description": "แสดงถึงโชคชะตา และวาสนาโดยรวม"},
    {"id": 2, "name": "ทรัพย์สินเงินทอง", "description": "แสดงถึงความมั่งคั่ง และโชคลาภทางการเงิน"},
    {"id": 3, "name": "หลักฐานบ้านช่อง", "description": "แสดงถึงที่อยู่อาศัย และความมั่นคงในชีวิต"},
    {"id": 4, "name": "ญาติมิตรพี่น้อง", "description": "แสดงถึงความสัมพันธ์กับคนใกล้ชิด"},
    {"id": 5, "name": "บุตรบริวาร", "description": "แสดงถึงลูกหลานและผู้ใต้บังคับบัญชา"},
    {"id": 6, "name": "ศัตรูอุปสรรค", "description": "แสดงถึงปัญหาและอุปสรรคที่กำลังเผชิญ"},
    {"id": 7, "name": "คู่ครองคนรัก", "description": "แสดงถึงความสัมพันธ์กับคู่ครองหรือคนรัก"},
    {"id": 8, "name": "โรคภัยพิบัติ", "description": "แสดงถึงสุขภาพและภัยอันตรายที่อาจเกิดขึ้น"},
    {"id": 9, "name": "ความสุขความสมหวัง", "description": "แสดงถึงสิ่งที่จะทำให้มีความสุขและความสำเร็จ"},
    {"id": 10, "name": "การงานและอาชีพ", "description": "แสดงถึงความก้าวหน้าและความสำเร็จในหน้าที่การงาน"},
    {"id": 11, "name": "ลาภยศชื่อเสียง", "description": "แสดงถึงเกียรติยศ ชื่อเสียง และการยอมรับ"},
    {"id": 12, "name": "สรุปคำทำนาย", "description": "แสดงถึงภาพรวมและจุดหมายปลายทาง"}
  ];

  final List<Map<String, dynamic>> allCards = [
    {"id": 1, "name": "พระพิฆเนศทรงหนู", "image": "/api/placeholder/160/240", "meaning": "การเริ่มต้นใหม่ ความสำเร็จ"},
    {"id": 2, "name": "พระโคนนทิ", "image": "/api/placeholder/160/240", "meaning": "ความรับผิดชอบ ความอดทน"},
    {"id": 3, "name": "พระแม่อุมา", "image": "/api/placeholder/160/240", "meaning": "อำนาจ บารมี ความน่าเกรงขาม"},
    {"id": 4, "name": "เทพธิดาพระจันทร์", "image": "/api/placeholder/160/240", "meaning": "ความงาม ความสดชื่น ความสบาย"},
    {"id": 5, "name": "พระนารายณ์บรรทมสินธุ์", "image": "/api/placeholder/160/240", "meaning": "การปกป้องคุ้มครอง การพักผ่อน"},
    {"id": 6, "name": "ท้าววิรูปักษ์", "image": "/api/placeholder/160/240", "meaning": "สัญชาตญาณ ไหวพริบ การเอาตัวรอด"},
    {"id": 7, "name": "พระอรุณเทพบุตร", "image": "/api/placeholder/160/240", "meaning": "การเดินทาง การเริ่มต้นใหม่"},
    {"id": 8, "name": "พระทักษะ", "image": "/api/placeholder/160/240", "meaning": "การเปลี่ยนแปลง การต่อสู้กับปัญหา"},
    {"id": 9, "name": "หนุมาน", "image": "/api/placeholder/160/240", "meaning": "ความท้าทาย การตัดสินใจรอบคอบ"},
    {"id": 10, "name": "พญาสุครีพ", "image": "/api/placeholder/160/240", "meaning": "การเริ่มต้นใหม่ ทักษะความสามารถ"},
    {"id": 11, "name": "กุมารทอง", "image": "/api/placeholder/160/240", "meaning": "ความสนุก อิสระ ความดื้อรั้น"},
    {"id": 12, "name": "นางเบญจกัลยาณี", "image": "/api/placeholder/160/240", "meaning": "ความอุดมสมบูรณ์ ศีลธรรม จิตใจบริสุทธิ์"},
  ];

  final String loremIpsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
  late List<Map<String, dynamic>> mockSummaryMeanings = [];
  final Map<int, Map<String, dynamic>> selectedCards = {};

  @override
  void initState() {
    super.initState();

    mockSummaryMeanings = [
      {"id": 1, "colorCode": "#007BFF", "header": "การงาน", "body": loremIpsum},
      {"id": 2, "colorCode": "#28A745", "header": "การเงิน", "body": loremIpsum},
      {"id": 3, "colorCode": "#FF4D6D", "header": "ความรัก", "body": loremIpsum},
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      title: 'ไพ่ 12 ตำแหน่ง',
      scrollController: scrollController,
      body: GridView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: cardPositions.length,
        itemBuilder: (context, index) => _buildPositionItem(context, index),
      ),
    );
  }

  Widget _buildPositionItem(BuildContext context, int index) {
    Map<String, dynamic> position = cardPositions[index];
    bool hasSelectedCard = selectedCards.containsKey(position["id"]);

    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (hasSelectedCard)
              Center(
                child: Text(
                  selectedCards[position["id"]]!["name"],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              const Center(
                child: Icon(
                  Icons.add_rounded,
                ),
              ),
            if (hasSelectedCard)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCards.remove(position["id"]);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "${position["id"]}. ${position["name"]}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () => hasSelectedCard
          ? Get.toNamed(
              RoutePath.geminiPrediction,
              arguments: {
                'cardId': selectedCards[position["id"]]!["name"],
                'positionId': position['name'],
              },
            )
          : _showAllCardsBottomSheet(
              context,
              position: position,
            ),
    );
  }

  void _showAllCardsBottomSheet(BuildContext context, {Map<String, dynamic>? position}) {
    TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> filteredCards = List.from(allCards);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void filterCards(String query) {
              setSheetState(() {
                if (query.isEmpty) {
                  filteredCards = List.from(allCards);
                } else {
                  filteredCards = allCards.where((card) {
                    return card['name'].toString().toLowerCase().contains(query.toLowerCase());
                  }).toList();
                }
              });
            }

            return Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.90,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'เลือกไพ่',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                                  filterCards('');
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        filterCards(value);
                      },
                    ),
                  ),
                  const Divider(),
                  filteredCards.isEmpty
                      ? const Center(
                          child: Text(
                            'ไม่พบไพ่ที่ค้นหา',
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      : (position?['name'] != null)
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'เลือกไพ่ของตำแหน่ง ${position?['name']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            )
                          : Container(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredCards.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> cardItem = filteredCards[index];
                        return ListTile(
                          leading: const Icon(Icons.star),
                          title: Text(cardItem['name']),
                          subtitle: Text(cardItem['meaning']),
                          onTap: () {
                            var positionId = position?["id"];
                            if (positionId == null) {
                              return;
                            }

                            bool isDuplicate = selectedCards.values.any((card) => card['id'] == cardItem['id']);

                            if (isDuplicate) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('ไพ่ "${cardItem['name']}" ถูกเลือกไปแล้ว\nกรุณาเลือกไพ่อื่น'),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } else {
                              setState(() {
                                selectedCards[positionId] = cardItem;
                              });
                              Navigator.pop(context);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSummaryBottomSheet(BuildContext context, {String? positionName, String? selectedCardName}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.90,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'สรุปคำทำนาย',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              Text(
                'ไพ่ $selectedCardName',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'ตำแหน่ง $positionName',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    ...mockSummaryMeanings.map(
                      (e) {
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
                                      color: hexToColor(e['colorCode']),
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
                                          e['header'],
                                          style: Theme.of(context).textTheme.titleLarge,
                                        )),
                                    collapsed: Text(
                                      e['body'],
                                      style: Theme.of(context).textTheme.bodyMedium,
                                      softWrap: true,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    expanded: Text(
                                      e['body'],
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
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
