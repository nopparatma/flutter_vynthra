import 'package:flutter/material.dart';
import 'package:flutter_vynthra/app/app_controller.dart';
import 'package:flutter_vynthra/app/router.dart';
import 'package:get/get.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AppController _appController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _appController = Get.find<AppController>();

    // Setup animation
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    // Initialize app config
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(Duration(milliseconds: 500));

    final success = await _appController.initializeApp();

    if (success) {
      await Future.delayed(Duration(milliseconds: 1500));

      Get.offNamed(RoutePath.homePage);
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade600,
              Colors.blue.shade400,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo หรือชื่อแอพ
            FadeTransition(
              opacity: _animation,
              child: ScaleTransition(
                scale: _animation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.storage,
                      size: 60,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),

            // ชื่อแอพ
            FadeTransition(
              opacity: _animation,
              child: Text(
                'MongoDB Flutter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 48),

            // สถานะการโหลด
            Obx(() {
              if (_appController.isLoading.value) {
                return Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'กำลังโหลดข้อมูล...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                );
              }

              if (_appController.errorMessage.value.isNotEmpty) {
                return Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade300,
                      size: 48,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'เกิดข้อผิดพลาด',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _appController.errorMessage.value,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _initializeApp(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade700,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: Text('ลองใหม่'),
                    ),
                  ],
                );
              }

              return SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}
