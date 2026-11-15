import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vynthra/app/app_controller.dart';
import 'package:vynthra/app/env.dart';
import 'package:vynthra/app/router.dart';
import 'package:vynthra/ui/vy.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  final AppController _app = Get.find<AppController>();
  late final AnimationController _fade = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..forward();
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _start();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _version = Env.isProd ? 'Version ${info.version}' : 'Version ${info.version} (${Env.name})');
  }

  Future<void> _start() async {
    if (await _app.initializeApp()) Get.offNamed(RoutePath.homePage);
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VyBackground(
      image: Vy.eclipse,
      scrim: 0,
      child: SafeArea(
        child: Stack(children: [
          // the logo sits inside the dark disc of the eclipse
          Align(
            alignment: const Alignment(0, -0.38),
            child: FadeTransition(
              opacity: _fade,
              child: Image.asset(Vy.logo, width: 184, height: 184, semanticLabel: 'Vynthra'),
            ),
          ),
          Align(
            alignment: const Alignment(0, 0.42),
            child: Obx(() {
              if (_app.isLoading.value) {
                return Column(mainAxisSize: MainAxisSize.min, children: [
                  const SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 2.5, color: Vy.gold, backgroundColor: Color(0x2EFFFFFF))),
                  const SizedBox(height: 16),
                  Text('กำลังโหลดข้อมูล...', style: Vy.t(16, color: Vy.textSoft)),
                ]);
              }
              if (_app.errorMessage.value.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('เชื่อมต่อไม่สำเร็จ', style: Vy.t(22, bold: true)),
                    const SizedBox(height: 8),
                    Text('ตรวจสอบอินเทอร์เน็ต แล้วลองอีกครั้ง', textAlign: TextAlign.center, style: Vy.t(16, color: Vy.textSoft)),
                    const SizedBox(height: 20),
                    SizedBox(width: 220, child: VyGoldButton(label: 'ลองอีกครั้ง', onPressed: _start)),
                  ]),
                );
              }
              return const SizedBox.shrink();
            }),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Text(_version, textAlign: TextAlign.center, style: Vy.t(14, color: const Color(0xFFB5AFA3))),
          ),
        ]),
      ),
    );
  }
}
