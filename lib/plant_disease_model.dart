import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class PlantDiseaseModel {
  late Interpreter _interpreter;
  late List<String> _labels;
  late int _inputSize;

  Future<void> loadModel() async {
    _interpreter =
        await Interpreter.fromAsset('assets/plant_disease_model.tflite');
    _labels = (await rootBundle.loadString('assets/labels.txt'))
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    _inputSize = _interpreter.getInputTensor(0).shape[1];
  }

// Future<String> predict(File imageFile) async {
//   final image = img.decodeImage(await imageFile.readAsBytes());
//   final resized = img.copyResize(image!, width: _inputSize, height: _inputSize);

//   final input = List.generate(_inputSize, (y) => List.generate(_inputSize, (x) {
//     final pixel = resized.getPixel(x, y);
//     return [
//       pixel.r / 255.0,
//       pixel.g / 255.0,
//       pixel.b / 255.0,
//     ];
//   }));

//   final output = List.filled(_labels.length, 0.0).reshape([1, _labels.length]);
//   _interpreter.run([input], output);

//   final scores = List<double>.from(output[0]);
//   final index = scores.indexWhere((s) => s == scores.reduce((a, b) => a > b ? a : b));

//   return _labels[index];
// }

  Future<String> predict(File imageFile) async {
    final image = img.decodeImage(await imageFile.readAsBytes());
    final resized =
        img.copyResize(image!, width: _inputSize, height: _inputSize);

    final input = List.generate(
        _inputSize,
        (y) => List.generate(_inputSize, (x) {
              final pixel = resized.getPixel(x, y);
              return [
                pixel.r / 255.0,
                pixel.g / 255.0,
                pixel.b / 255.0,
              ];
            }));

    final output =
        List.filled(_labels.length, 0.0).reshape([1, _labels.length]);
    _interpreter.run([input], output);

    final scores = List<double>.from(output[0]);

    // 🔍 Trouver la probabilité max et son index
    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final maxIndex = scores.indexOf(maxScore);

    // ✅ Vérifier si c’est au-dessus du seuil (ex: 60%)
    if (maxScore < 0.6) {
      return "Image non reconnue";
    }

    return _labels[maxIndex];
  }
}
