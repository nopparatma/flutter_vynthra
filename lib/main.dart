import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'ไพ่ 12 ตำแหน่ง'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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

  final Map<int, Map<String, dynamic>> selectedCards = {};
  final ScrollController _scrollController = ScrollController();
  final double _appBarMinHeight = 0;
  final double _appBarMaxHeight = kToolbarHeight;
  double _appBarHeight = kToolbarHeight;
  bool _showTitle = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_appBarHeight > _appBarMinHeight) {
        setState(() {
          _appBarHeight = (_appBarHeight - 2).clamp(_appBarMinHeight, _appBarMaxHeight);
          _showTitle = false;
        });
      }
    }

    if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
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
        ),
      ),
      body: ListView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        children: [
          GridView.builder(
            padding: const EdgeInsets.all(8.0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            itemCount: cardPositions.length,
            itemBuilder: (context, index) => _buildPositionItem(context, index),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBottomSheet(context),
        child: const Icon(Icons.info_outline),
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
      onTap: () => hasSelectedCard ? null : _showBottomSheet(context, position: position),
    );
  }

  void _showBottomSheet(BuildContext context, {Map<String, dynamic>? position}) {
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
                        'ไพ่ทั้งหมด',
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
}
