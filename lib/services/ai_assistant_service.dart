import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AiAssistantService {
  final FlutterTts tts = FlutterTts();
  // 👇 غيّر هذا المفتاح بمفتاحك المجاني من Google AI Studio
  static const String apiKey = 'YOUR_GEMINI_API_KEY_HERE';

  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: apiKey,
  );

  // تهيئة الصوت العربي
  Future<void> initTts() async {
    await tts.setLanguage("ar-SA");
    await tts.setSpeechRate(0.5);
  }

  // السؤال الذكي مع فحص الصلاحيات
  Future<Map<String, String>> askSmart(String question, Map<String, dynamic> currentUser) async {
    String role = currentUser['role']?? 'cashier';
    String branchId = currentUser['branchId']?? '';
    String userName = currentUser['name']?? 'المستخدم';
    List permissions = currentUser['permissions']?? [];

    // فحص الصلاحيات قبل ما يجاوب
    if (question.contains('فرع') &&!question.contains(branchId) && role == 'branch_manager') {
      if (!permissions.contains('view_all_branches')) {
        return {
          'text': 'عذراً يا $userName، ليس لديك صلاحية للاطلاع على فروع أخرى. صلاحيتك فقط على فرع $branchId',
          'type': 'permission_denied'
        };
      }
    }

    String prompt = '''
أنت سكرتير ذكي اسمه "ميتاموت" داخل نظام محاسبي ERP.
المستخدم: $userName - دوره: $role - فرعه: $branchId - صلاحياته: $permissions

القواعد:
1. جاوب فقط ضمن صلاحياته
2. إذا سأل عن شيء خارج صلاحيته قل له باحترام ليس لديه صلاحية
3. جاوب باللهجة اليمنية البيضاء باختصار ومباشرة
4. إذا سأل عن تقرير، اعط ارقام واقعية من السياق

السؤال: $question

جاوب الآن:
''';

    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      String answer = response.text?? 'ما فهمت سؤالك، ممكن توضح أكثر؟';

      // تكلم الرد
      await tts.speak(answer);

      return {'text': answer, 'type': 'success'};
    } catch (e) {
      return {'text': 'حصل خطأ في الاتصال بالذكاء الاصطناعي: $e', 'type': 'error'};
    }
  }

  // تقرير الحضور الحقيقي من Firebase
  Future<String> getRealAttendanceReport(String branchId) async {
    try {
      String today = DateTime.now().toIso8601String().split('T')[0];
      var snapshot = await FirebaseFirestore.instance
         .collection('attendance')
         .where('branchId', isEqualTo: branchId)
         .where('date', isEqualTo: today)
         .get();

      if (snapshot.docs.isEmpty) return 'لا يوجد حضور مسجل اليوم في فرع $branchId';

      String report = 'تقرير حضور اليوم $today:\n';
      for (var doc in snapshot.docs) {
        String name = doc['employeeName']?? 'موظف';
        String time = doc['checkInTime']?? 'غير معروف';
        String status = doc['status']?? 'حاضر';
        report += '- $name حضر الساعة $time ($status)\n';
      }
      return report;
    } catch (e) {
      return 'خطأ في جلب تقرير الحضور';
    }
  }

  // مقارنة المبيعات
  Future<String> getSalesComparison(String branchId) async {
    try {
      DateTime now = DateTime.now();
      String today = now.toIso8601String().split('T')[0];
      String yesterday = now.subtract(Duration(days: 1)).toIso8601String().split('T')[0];

      var todaySales = await FirebaseFirestore.instance
         .collection('invoices').where('branchId', isEqualTo: branchId).where('date', isEqualTo: today).get();

      double todayTotal = 0;
      for(var d in todaySales.docs) { todayTotal += (d['total']?? 0); }

      var yesterdaySales = await FirebaseFirestore.instance
         .collection('invoices').where('branchId', isEqualTo: branchId).where('date', isEqualTo: yesterday).get();

      double yesterdayTotal = 0;
      for(var d in yesterdaySales.docs) { yesterdayTotal += (d['total']?? 0); }

      if (todayTotal > yesterdayTotal) {
        return 'مبيعات اليوم $todayTotal ريال، أفضل من أمس اللي كان $yesterdayTotal ريال، بزيادة ${(todayTotal - yesterdayTotal)} ريال. ما شاء الله حركة ممتازة!';
      } else {
        return 'مبيعات اليوم $todayTotal ريال، أقل من أمس اللي كان $yesterdayTotal ريال. أمس كان أفضل.';
      }
    } catch (e) {
      return 'ما قدرت أجيب بيانات المبيعات الآن';
    }
  }
}