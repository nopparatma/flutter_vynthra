import 'package:vynthra/models/card_model.dart';
import 'package:vynthra/models/position_model.dart';
import 'package:vynthra/modules/gemini_prediction/constants.dart';

class PromptAi {
  final CardModel? cardItem;
  final PositionModel? positionItem;
  final String? question;
  final PromptType? promptType;

  PromptAi({
    this.cardItem,
    this.positionItem,
    this.question,
    required this.promptType,
  });

  String getPrompt() {
    if (PromptType.standard == promptType) {
      return generatePromptStandard();
    }

    if (PromptType.fortune == promptType) {
      return generatePromptFortune();
    }

    if (PromptType.question == promptType) {
      // TODO : question
      return "question";
    }

    return "";
  }

  String generatePromptStandard() {
    return '''  คุณคือหมอดูที่มีความเชี่ยวชาญในการอ่านไพ่และสามารถแปลความหมายของไพ่ตามบริบทของตำแหน่งที่วางได้อย่างแม่นยำ
                โดยให้ตอบออกมาให้ค่อนข้างให้ความรู้สึกจริงจังและดูน่าเชื่อถือ ชัดเจน และตรงประเด็น

                ผู้รับคำทำนายได้เลือกไพ่ "${cardItem?.name.th}" และถูกวางที่ตำแหน่ง "${positionItem?.name.th}"
                
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
                $standardHtmlDataFromAIExample ''';
  }

  String generatePromptFortune() {
    return '''  คุณคือหมอดูที่มีความเชี่ยวชาญในการอ่านไพ่และสามารถแปลความหมายของไพ่ จากนั้นตอบคำถามตามบริบทของคำถามที่ผู้ใช้ถามเข้ามาได้อย่างแม่นยำ
                โดยให้ตอบออกมาให้ค่อนข้างให้ความรู้สึกจริงจังและดูน่าเชื่อถือ ชัดเจน และตรงประเด็น ไม่ต้องการคำตอบแบบกว้างๆ

                ผู้รับคำทำนายได้เลือกไพ่ "${cardItem?.name.th}" และคำถามคือ "${question ?? ''}"
                
                ข้อมูลหลักของไพ่ :
                [รายละเดียด = ${cardItem?.getDescriptionText(lang: 'th')}, การพยากรณ์และคำทำนายโดยละเอียด = ${cardItem?.getPredictionText(lang: 'th')}]
                
                โจทย์ :
                ให้คุณทำการทำนายโดยพิจารณา และแปลความหมายของไพ่ จากนั้นตอบคำถามตามบริบทของคำถามที่ผู้ใช้ถามเข้ามา
                
                รูปแบบผลลัพธ์ที่ต้องการ :
                1.ระบุชื่อไพ่และตำแหน่งที่ไพ่อยู่
                2.นำข้อมูลหลักของไพ่มาประกอบการทำนาย
                3.แปลความหมายของไพ่ และตอบคำถาม
                4.ให้คำแนะนำเพิ่มเติม
                5.สรุป
                
                ตัวอย่างผลลัพธ์ที่ต้องการแสดงผลเป็น HTML :
                $fortuneHtmlDataFromAIExample ''';
  }

  @override
  String toString() {
    return 'PromptAi{cardItem: $cardItem, positionItem: $positionItem, question: $question, promptType: $promptType}';
  }
}
