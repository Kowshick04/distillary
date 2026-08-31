import 'dart:convert';
import 'package:flutter/services.dart';

class RandomForestPredictor {
  static final RandomForestPredictor _instance = RandomForestPredictor._internal();
  factory RandomForestPredictor() => _instance;
  RandomForestPredictor._internal();

  bool _isLoaded = false;
  late Map<String, dynamic> _modelData;
  late List<dynamic> _estimators;
  late List<int> _classes;
  late List<String> _featureNames;

  bool get isLoaded => _isLoaded;

  /// Loads the exported JSON model from assets.
  Future<void> loadModel() async {
    if (_isLoaded) return;
    try {
      final jsonString = await rootBundle.loadString('assets/model/rf_model.json');
      _modelData = jsonDecode(jsonString) as Map<String, dynamic>;
      _estimators = _modelData['estimators'] as List<dynamic>;
      _classes = List<int>.from(_modelData['classes'] as List<dynamic>);
      _featureNames = List<String>.from(_modelData['feature_names'] as List<dynamic>);
      _isLoaded = true;
    } catch (e) {
      print("RandomForestPredictor: Error loading model JSON: $e");
    }
  }

  /// Predicts the class label and confidence score from raw features.
  Map<String, dynamic> predict(Map<String, double> inputs) {
    if (!_isLoaded) {
      return {
        'predictionLabel': 'normal',
        'confidence': 75.0,
      };
    }

    final List<double> features = _featureNames.map((name) => inputs[name] ?? 0.0).toList();
    final List<double> classProbabilities = List<double>.filled(_classes.length, 0.0);

    for (final estimator in _estimators) {
      final left = List<int>.from(estimator['children_left'] as List<dynamic>);
      final right = List<int>.from(estimator['children_right'] as List<dynamic>);
      final nodeFeature = List<int>.from(estimator['feature'] as List<dynamic>);
      final threshold = List<double>.from((estimator['threshold'] as List<dynamic>).map((e) => (e as num).toDouble()));
      final valueDist = estimator['value'] as List<dynamic>;

      int currentNode = 0;
      while (left[currentNode] != -1 && right[currentNode] != -1) {
        final int splitFeatIdx = nodeFeature[currentNode];
        final double splitVal = features[splitFeatIdx];
        final double splitThresh = threshold[currentNode];

        if (splitVal <= splitThresh) {
          currentNode = left[currentNode];
        } else {
          currentNode = right[currentNode];
        }
      }

      final List<dynamic> counts = valueDist[currentNode][0] as List<dynamic>;
      double total = 0.0;
      for (final val in counts) {
        total += (val as num).toDouble();
      }

      if (total > 0.0) {
        for (int i = 0; i < counts.length; i++) {
          classProbabilities[i] += ((counts[i] as num).toDouble() / total) / _estimators.length;
        }
      }
    }

    int bestClassIdx = 0;
    double maxProb = -1.0;
    for (int i = 0; i < classProbabilities.length; i++) {
      if (classProbabilities[i] > maxProb) {
        maxProb = classProbabilities[i];
        bestClassIdx = i;
      }
    }

    final int predictedClassInt = _classes[bestClassIdx];
    final String label = _mapClassToLabel(predictedClassInt);
    final double confidencePct = (maxProb * 100.0).clamp(50.0, 100.0);

    return {
      'predictionLabel': label,
      'confidence': confidencePct,
    };
  }

  String _mapClassToLabel(int classInt) {
    switch (classInt) {
      case 0:
        return 'low_alcohol';
      case 2:
        return 'golden';
      case 1:
      default:
        return 'normal';
    }
  }
}

final randomForestPredictor = RandomForestPredictor();
