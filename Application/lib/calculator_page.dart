import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:graduation_project_depi/controllers/calculator_page_controller.dart';
import 'package:graduation_project_depi/services/auth_service.dart';

class CalculatorPage extends GetView<CalculatorPageController> {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            "Electricity Bill Calculator",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF1565C0),

          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                final service = Get.find<AuthService>();
                service.logout();
                Get.offAllNamed('/login');
                Get.snackbar(
                  "Logged Out",
                  "You have been logged out successfully!",
                  backgroundColor: Colors.blue.shade400,
                  colorText: Colors.white,
                );
              },
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 20,
                      children: [
                        const Text(
                          "Electricity Bill Calculator",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                        Obx(() {
                          return controller.isLoading.value
                              ? Column(
                                  children: const [
                                    SizedBox(height: 10),
                                    SpinKitWave(
                                      color: Colors.yellow,
                                      size: 50.0,
                                    ),
                                    SizedBox(height: 10),
                                    Text("Reading numbers from image..."),
                                  ],
                                )
                              : const SizedBox();
                        }),
                        TextField(
                          controller: controller.previousReadingController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Previous Reading",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.camera_alt,
                                color: Colors.orange,
                              ),
                              onPressed: () => controller.scanForField(
                                controller.previousReadingController,
                                context,
                              ),
                            ),
                          ),
                        ),

                        TextField(
                          controller: controller.currentReadingController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Current Reading",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.camera_alt,
                                color: Colors.orange,
                              ),
                              onPressed: () => controller.scanForField(
                                controller.currentReadingController,
                                context,
                              ),
                            ),
                          ),
                        ),

                        ElevatedButton(
                          onPressed: () => controller.calculate(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 50),
                          ),
                          child: Text(
                            "Calculate",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),

                        Obx(
                          () => Text(controller.cost.value, style: resultStyle),
                        ),

                        Obx(
                          () => Text(
                            controller.consumption.value,
                            style: resultStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _field(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );

  final resultStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Color(0xFF0D47A1),
  );
}
