import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:vynthra/app/app_controller.dart';
import 'package:vynthra/models/card_model.dart';
import 'package:vynthra/models/position_model.dart';
import 'package:vynthra/services/api_client.dart';
import 'package:vynthra/utils/shared_pref_util.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Short name and one line about each house, in seq order (1 = วาสนา … 12 = ไพ่สรุปคำทำนาย).
const houseShort = ['วาสนา', 'การเงิน', 'บ้านเรือน', 'ญาติมิตร', 'บุตรบริวาร', 'อุปสรรค', 'คู่ครอง', 'สุขภาพ', 'ความสุข', 'การงาน', 'ชื่อเสียง', 'ไพ่สรุป'];
const houseAbout = [
  'พื้นดวงและโชคชะตาโดยรวมของคุณ',
  'เรื่องเงินและทรัพย์สิน',
  'บ้าน ที่อยู่ และความมั่นคง',
  'คนในครอบครัวและเพื่อนฝูง',
  'ลูกและคนในความดูแล',
  'สิ่งที่ขวางทางและคนที่ไม่หวังดี',
  'เรื่องความรักและคนเคียงข้าง',
  'สุขภาพและสิ่งที่ควรระวัง',
  'ความสุขและสิ่งที่จะสมหวัง',
  'หน้าที่การงานและอาชีพ',
  'โชคลาภ ตำแหน่ง และชื่อเสียง',
  'ภาพรวมของคำทำนายทั้งหมด',
];

enum HousesPhase { dealing, revealing, paused, open }

/// A reading only lives in memory. Opening a later screen of it directly (a reload on the web)
/// finds nothing, so send the person back to Home instead.
bool housesReadingMissing() {
  if (Get.isRegistered<HousesController>()) return false;
  WidgetsBinding.instance.addPostFrameCallback((_) => Get.offAllNamed('/home'));
  return true;
}

/// One 12-house reading: draws the cards, asks for all twelve readings at once,
/// and paces the laying and turning of the cards so the wait is the ritual itself.
class HousesController extends GetxController {
  static const int count = 12;
  static const Duration dealStep = Duration(milliseconds: 2500);
  static const Duration minRevealStep = Duration(milliseconds: 1800);

  final AppController app = Get.find<AppController>();

  late final List<PositionModel> positions;
  late final List<CardModel> cards;

  final phase = HousesPhase.dealing.obs;
  final placed = 0.obs; // cards laid face down
  final revealed = 0.obs; // cards turned face up
  final selected = RxnInt();
  final readSet = <int>{}.obs;

  final List<String?> readings = List.filled(count, null);
  final List<bool> failed = List.filled(count, false);
  final _arrived = StreamController<int>.broadcast();

  bool _closed = false;

  @override
  void onInit() {
    super.onInit();
    positions = ([...app.positions]..sort((a, b) => a.seq.compareTo(b.seq))).take(count).toList();
    cards = ([...app.cards]..shuffle(Random())).take(count).toList();
  }

  /// Called once the thumbs have been held long enough.
  void begin() {
    _awake(true);
    for (var i = 0; i < count; i++) {
      _fetch(i);
    }
    _run();
  }

  Future<void> _run() async {
    phase.value = HousesPhase.dealing;
    while (placed.value < count) {
      await Future.delayed(dealStep);
      if (_closed) return;
      placed.value++;
    }
    await _revealFrom(revealed.value);
  }

  Future<void> _revealFrom(int start) async {
    phase.value = HousesPhase.revealing;
    for (var i = start; i < count; i++) {
      final shown = DateTime.now();
      while (readings[i] == null && !failed[i]) {
        try {
          await _arrived.stream.firstWhere((n) => n == i || failed[i] || readings[i] != null);
        } on StateError {
          return; // the reading was closed while waiting
        }
        if (_closed) return;
      }
      if (readings[i] == null) {
        phase.value = HousesPhase.paused;
        _awake(false);
        return;
      }
      final waited = DateTime.now().difference(shown);
      if (i > start && waited < minRevealStep) await Future.delayed(minRevealStep - waited);
      if (_closed) return;
      revealed.value = i + 1;
    }
    phase.value = HousesPhase.open;
    _awake(false);
  }

  /// "เปิดไพ่ต่อ" on the paused screen: ask again for whatever is still missing and carry on.
  void resume() {
    _awake(true);
    for (var i = 0; i < count; i++) {
      if (readings[i] == null && failed[i]) {
        failed[i] = false;
        _fetch(i);
      }
    }
    _revealFrom(revealed.value);
  }

  /// Keep the screen on during the ritual. Browsers may refuse; the reading goes on regardless.
  void _awake(bool on) {
    (on ? WakelockPlus.enable() : WakelockPlus.disable()).catchError((Object e) => debugPrint('wakelock: $e'));
  }

  void _signal(int i) {
    if (!_arrived.isClosed) _arrived.add(i);
  }

  String _cacheKey(int i) => '${cards[i].id}_${positions[i].id}';

  Future<void> _fetch(int i) async {
    final cached = await SharedPrefUtil.read(_cacheKey(i));
    if (cached is String && cached.isNotEmpty) {
      readings[i] = cached;
      _signal(i);
      return;
    }
    // two quiet retries for ordinary errors; a busy server ("rate_limited") is given longer to clear
    var attempt = 0, busy = 0;
    while (!_closed) {
      try {
        final res = await app.api.post('/v1/predictions', {'type': 'standard', 'cardId': cards[i].id, 'positionId': positions[i].id});
        final html = '${res['html'] ?? ''}';
        if (html.isEmpty) throw ApiException(code: 'empty', message: 'empty reading');
        readings[i] = html;
        SharedPrefUtil.save(_cacheKey(i), html);
        _signal(i);
        return;
      } catch (e) {
        debugPrint('house $i: $e');
        if (e is ApiException && e.code == 'rate_limited' && busy < 5) {
          busy++;
          await Future.delayed(const Duration(seconds: 15));
          continue;
        }
        if (attempt < 2) {
          attempt++;
          await Future.delayed(Duration(seconds: attempt * 4));
          continue;
        }
        failed[i] = true;
        _signal(i);
        return;
      }
    }
  }

  void tapCard(int i) {
    if (phase.value != HousesPhase.open) return;
    selected.value = selected.value == i ? null : i;
  }

  void markRead(int i) => readSet.add(i);

  @override
  void onClose() {
    _closed = true;
    _arrived.close();
    _awake(false);
    super.onClose();
  }
}
