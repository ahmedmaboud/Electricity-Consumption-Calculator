import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRPage extends StatelessWidget {
  OCRPage({super.key});

  final result = ''.obs;
  final isLoading = false.obs;
  final picker = ImagePicker();

  // Function to show BottomSheet for choosing source
  Future<void> _showPicker(BuildContext context) async {
    showModalBottomSheet(
      elevation: 10,
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to pick image and run OCR
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    isLoading.value = true;

    final inputImage = InputImage.fromFile(File(pickedFile.path));
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );

    String numbers = '';
    for (var block in recognizedText.blocks) {
      for (var line in block.lines) {
        final matches = RegExp(r'\d+').allMatches(line.text);
        for (var m in matches) {
          numbers += '${m.group(0)} ';
        }
      }
    }
    result.value = numbers.trim();

    await textRecognizer.close();

    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.electric_bolt, color: Colors.amberAccent),
        actions: [
          Icon(Icons.electric_bolt, color: Colors.amberAccent),
          SizedBox(width: 15),
        ],
        title: Center(
          child: Text("Extract Numbers", style: TextStyle(color: Colors.white)),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Extracted Numbers:", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Obx(() {
              if (isLoading.value) {
                return Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text("Processing image...", style: TextStyle(fontSize: 16)),
                  ],
                );
              } else {
                return Text(
                  result.value.isEmpty ? "No numbers found yet" : result.value,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                );
              }
            }),

            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _showPicker(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: Text(
                "Select Image",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
