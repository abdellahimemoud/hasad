import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hasad_app/models/detection_result.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hasad_app/plant_disease_model.dart';
import 'package:hasad_app/disease_descriptions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class MaladiePage extends StatefulWidget {
  const MaladiePage({super.key});

  @override
  State<MaladiePage> createState() => _MaladiePageState();
}

class _MaladiePageState extends State<MaladiePage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  PlantDiseaseModel? _model;
  String? _prediction;
  String? _description;

  @override
  void initState() {
    super.initState();
    _model = PlantDiseaseModel();
    _model!.loadModel(); // Load the ML model
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _prediction = null;
        _description = null;
      });
      await _analyzeImage();
    }
  }

  // Future<void> _analyzeImage() async {
  //   if (_imageFile != null && _model != null) {
  //     final label = await _model!.predict(_imageFile!);
  //     final desc = diseaseDescriptions[label] ?? "No description available.";
  //     setState(() {
  //       _prediction = label;
  //       _description = desc;
  //     });
  //   }
  // }
  Future<void> _analyzeImage() async {
    if (_imageFile != null && _model != null) {
      final label = await _model!.predict(_imageFile!);

      final desc = diseaseDescriptions[label] ??
          (label == "Image non reconnue"
              ? "L’image ne semble pas contenir une plante valide. Veuillez réessayer avec une photo claire de la feuille ou du fruit."
              : "Aucune description disponible.");

      setState(() {
        _prediction = label;
        _description = desc;
      });

      // ✅ Sauvegarde dans Hive
      final result = DetectionResult(
        label: label,
        description: desc,
        imagePath: _imageFile!.path,
        date: DateTime.now(),
      );

      try {
        final box = await Hive.openBox<DetectionResult>('detection_results');
        await box.add(result);
      } catch (e) {
        print("Error saving result: $e");
      }
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      //backgroundColor: const Color(0xFFF9F4E6),

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  size: 32, color: Color(0xFF173F35)),
              title:  Text(AppLocalizations.of(context)!.takePhoto,
                  style: TextStyle(fontSize: 18, color: Color(0xFF173F35))),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading:
                  const Icon(Icons.photo, size: 32, color: Color(0xFF173F35)),
              title:  Text(AppLocalizations.of(context)!.chooseFromGalery,
                  style: TextStyle(fontSize: 18, color: Color(0xFF173F35))),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            children: [
               Text(
                AppLocalizations.of(context)!.captOrSelect,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF173F35)),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _showImageSourceOptions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 37, 100, 84),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                ),
                icon: const Icon(Icons.spa_outlined, color: Colors.white),
                label:  Text(
                  AppLocalizations.of(context)!.buttDetect,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),
              if (_imageFile != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    _imageFile!,
                    height: 220,
                  ),
                ),
              if (_prediction != null && _description != null) ...[
                const SizedBox(height: 30),
                // Text(
                //   "Result: $_prediction",
                //   style: const TextStyle(
                //       fontWeight: FontWeight.bold,
                //       fontSize: 18,
                //       color: Color(0xFF173F35)),
                // ),
                // const SizedBox(height: 10),
                // Text(
                //   _description!,
                //   style:
                //       const TextStyle(fontSize: 14, color: Color(0xFF173F35)),
                //   textAlign: TextAlign.justify,
                // ),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _prediction == "Image non reconnue"
                            ? "❗ Image non reconnue"
                            : "🩺 Résultat : $_prediction",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _description ?? "",
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
