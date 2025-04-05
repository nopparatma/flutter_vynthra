import 'package:vynthra/models/card_model.dart';
import 'package:vynthra/models/position_model.dart';

class PromptAi {
  final CardModel? cardItem;
  final PositionModel? positionItem;
  final String htmlExample;

  PromptAi({
    required this.cardItem,
    required this.positionItem,
    required this.htmlExample,
  });

  String generatePrompt() {
    return '''  คุณคือหมอดูที่มีความเชี่ยวชาญในการอ่านไพ่และสามารถแปลความหมายของไพ่ตามบริบทของตำแหน่งที่วางได้อย่างแม่นยำ
                โดยให้ตอบออกมาให้เป็นกันเองมากที่สุด

                ผู้รับคำทำนายได้เลือก "${cardItem?.name.th}" และถูกวางที่ตำแหน่ง "${positionItem?.name.th}"
                
                ข้อมูลหลักของไพ่ :
                [รายละเดียด = ${cardItem?.getDescriptionText(lang: 'th')}, การพยากรณ์และคำทำนายโดยละเอียด = ${cardItem?.getPredictionText(lang: 'th')}]
                
                ข้อมูลตำแหน่ง :
                [${positionItem?.getDescriptionText(lang: 'th')}]
                
                โจทย์ :
                ให้คุณทำการทำนายโดยพิจารณา และแปลความหมายของไพ่ตามบริบทของตำแหน่งนั้นๆ
                
                รูปแบบผลลัพธ์ที่ต้องการ :
                1.ระบุชื่อไพ่และตำแหน่งที่ไพ่อยู่
                2.นำข้อมูลหลักของไพ่มาประกอบการทำนาย
                3.แปลความหมายของไพ่ในบริบทของตำแหน่งนั้น
                4.ให้คำแนะนำเพิ่มเติม
                5.สรุป
                
                ตัวอย่างผลลัพธ์ที่ต้องการแสดงผลเป็น HTML :
                $htmlExample ''';
  }

  @override
  String toString() {
    return 'PromptAi{cardItem: $cardItem, positionItem: $positionItem, htmlExample: $htmlExample}';
  }
}
