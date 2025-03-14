class PromptAi {
  final String cardName;
  final String positionName;
  final String cardInfo;
  final String positionInfo;
  final String htmlExample;

  PromptAi({
    required this.cardName,
    required this.positionName,
    required this.cardInfo,
    required this.positionInfo,
    required this.htmlExample,
  });

  String generatePrompt() {
    return '''  คุณคือหมอดูที่มีความเชี่ยวชาญในการอ่านไพ่และสามารถแปลความหมายของไพ่ตามบริบทของตำแหน่งที่วางได้อย่างแม่นยำ

                ผู้รับคำทำนายได้เลือก "$cardName" และถูกวางที่ตำแหน่ง "$positionName"
                
                ข้อมูลหลักของไพ่ :
                "$cardInfo"
                
                ข้อมูลตำแหน่ง :
                "$positionInfo"
                
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
    return 'PromptAi{cardName: $cardName, positionName: $positionName, cardInfo: $cardInfo, positionInfo: $positionInfo, htmlExample: $htmlExample}';
  }
}
