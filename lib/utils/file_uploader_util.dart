import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'dart:convert';
import '../widgets/dashboard/ai_operator_advisor.dart';
import '../widgets/dashboard/initial_gap_table.dart';
import '../utils/app_colors.dart';

class ParsedBatchData {
  final String title;
  final double levelFactor;
  final String stateText;
  final double temperature;
  final double ph;
  final double brix;
  final String qualityFlag;
  final double confidence;
  final bool isRecoverable;
  final double volatileAcidityPpm;
  final List<QCEntry> qcActions;
  final List<GapTableEntry> gapEntries;
  final List<double> brixHistory;
  final List<double> alcoholHistory;
  final List<double> tempHistory;
  final double yeastCount;
  final int fermenterIndex;

  ParsedBatchData({
    required this.title,
    required this.levelFactor,
    required this.stateText,
    required this.temperature,
    required this.ph,
    required this.brix,
    required this.qualityFlag,
    required this.confidence,
    required this.isRecoverable,
    required this.volatileAcidityPpm,
    required this.qcActions,
    required this.gapEntries,
    required this.brixHistory,
    required this.alcoholHistory,
    required this.tempHistory,
    required this.yeastCount,
    required this.fermenterIndex,
  });
}

class FileUploaderUtil {
  static Future<ParsedBatchData?> pickAndParseBatchFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx'],
      );

      if (result == null || result.files.isEmpty) return null;

      final PlatformFile file = result.files.first;
      final String filename = file.name;
      final String filePath = file.path!;
      
      int localFermenterIndex = -1;

      // Attempt Python AI Inference execution first
      try {
        final processResult = await Process.run('python', [
          'C:\\fermentation app\\models\\predict_from_file.py',
          filePath,
        ]);

        if (processResult.exitCode == 0) {
          final String stdoutText = processResult.stdout.toString().trim();
          final Map<String, dynamic> jsonPayload = json.decode(stdoutText);

          if (!jsonPayload.containsKey('error')) {
            final String predictedLabel = jsonPayload['predicted_label'].toString().toUpperCase();
            final double confidence = (jsonPayload['confidence'] as num).toDouble();
            final bool recoverable = jsonPayload['recoverable'] as bool;
            final double yeastVal = (jsonPayload['yeast_count'] as num).toDouble();
            final double vaVal = (jsonPayload['volatile_acidity'] as num).toDouble();
            final double phVal = (jsonPayload['ph'] as num).toDouble();
            
            final List<dynamic> suggestions = jsonPayload['suggestions'] ?? [];
            final List<dynamic> rootCauses = jsonPayload['root_causes'] ?? [];

            final List<QCEntry> actionsList = [];
            for (var s in suggestions) {
              actionsList.add(QCEntry(action: s.toString(), description: 'Correction guidance from trained RandomForest model.'));
            }
            for (var r in rootCauses) {
              actionsList.add(QCEntry(action: 'WARNING: $r', description: 'Critical bottleneck cause logged.'));
            }

            final List<double> brixList = (jsonPayload['brix_history'] as List)
                .map((e) => (e as num).toDouble())
                .toList();
            final List<double> alcList = (jsonPayload['alcohol_history'] as List)
                .map((e) => (e as num).toDouble())
                .toList();
            final List<double> tempList = (jsonPayload['temp_history'] as List)
                .map((e) => (e as num).toDouble())
                .toList();

            final List<GapTableEntry> gapsList = [
              GapTableEntry(
                metric: 'Yeast Count',
                activeVal: '${yeastVal.toStringAsFixed(0)} x 10^6',
                goldenVal: '300+ x 10^6',
                statusText: yeastVal >= 300 ? 'Optimal' : 'Sub-optimal',
                statusColor: yeastVal >= 300 ? AppColors.cyan : AppColors.amber,
              ),
              GapTableEntry(
                metric: 'Volatile Acids',
                activeVal: '${vaVal.toStringAsFixed(0)} ppm',
                goldenVal: '< 1500 ppm',
                statusText: vaVal < 1500 ? 'Optimal' : 'CRITICAL INFECTION',
                statusColor: vaVal < 1500 ? AppColors.cyan : AppColors.red,
              ),
              GapTableEntry(
                metric: 'pH',
                activeVal: phVal.toStringAsFixed(2),
                goldenVal: '4.5 - 5.0',
                statusText: (phVal >= 4.5 && phVal <= 5.0) ? 'Optimal' : 'Sub-optimal',
                statusColor: (phVal >= 4.5 && phVal <= 5.0) ? AppColors.cyan : AppColors.amber,
              ),
            ];

            final int fIdx = jsonPayload['fermenter_index'] ?? -1;

            return ParsedBatchData(
              title: 'Attached: ${filename.length > 15 ? "${filename.substring(0, 12)}..." : filename}',
              levelFactor: 0.90,
              stateText: 'FERMENTING',
              temperature: tempList.isEmpty ? 30.0 : tempList.last,
              ph: phVal,
              brix: brixList.isEmpty ? 5.0 : brixList.last,
              qualityFlag: predictedLabel == 'GOLDEN' ? 'GOLDEN BATCH' : predictedLabel,
              confidence: confidence,
              isRecoverable: recoverable,
              volatileAcidityPpm: vaVal,
              qcActions: actionsList,
              gapEntries: gapsList,
              brixHistory: brixList,
              alcoholHistory: alcList,
              tempHistory: tempList,
              yeastCount: yeastVal,
              fermenterIndex: fIdx,
            );
          }
        }
      } catch (innerErr) {
        if (kDebugMode) print('Python inference failed: $innerErr. Falling back to local Dart rule parser.');
      }

      // Fallback Strategy: Local Dart Heuristics Parser (same as before)
      double tempSum = 0.0;
      double phSum = 0.0;
      double brixSum = 0.0;
      int rowCount = 0;

      final List<double> brixList = [];
      final List<double> alcList = [];
      final List<double> tempList = [];

      double yeastCountMillions = 245.0;
      double volatileAcidsPpm = 1150.0;

      if (filename.toLowerCase().endsWith('.xlsx')) {
        final bytes = file.bytes ?? await File(filePath).readAsBytes();
        final decoder = SpreadsheetDecoder.decodeBytes(bytes, update: false);
        
        if (decoder.tables.isEmpty) return null;
        final sheetName = decoder.tables.keys.first;
        final table = decoder.tables[sheetName];

        if (table == null || table.rows.isEmpty) return null;

        final rawHeaderRow = table.rows.first;
        // Wrap as nullable list for API compatibility
        final headerRow = rawHeaderRow.map((v) => v).toList();
        int tempCol = -1;
        int phCol = -1;
        int brixCol = -1;
        int alcCol = -1;
        int yeastCol = -1;
        int vaCol = -1;
        int fermenterCol = -1;

        for (int i = 0; i < headerRow.length; i++) {
          final val = headerRow[i]?.toString().toLowerCase() ?? '';
          if (val.contains('temp')) {
            tempCol = i;
          } else if (val.contains('ph')) phCol = i;
          else if (val.contains('brix')) brixCol = i;
          else if (val.contains('alcohol') || val.contains('alc')) alcCol = i;
          else if (val.contains('yeast')) yeastCol = i;
          else if (val.contains('volatile') || val.contains('va')) vaCol = i;
          else if (val.contains('fermenter') || val.contains('fermentor') || val.contains('vessel') || val.contains('bioreactor')) fermenterCol = i;
        }

        // Extract fermenter once from the first data row (row 1)
        if (fermenterCol != -1 && table.rows.length > 1) {
          final firstDataRow = table.rows[1];
          if (fermenterCol < firstDataRow.length) {
            final fVal = firstDataRow[fermenterCol]?.value?.toString().toLowerCase() ?? '';
            if (fVal.contains('1') || fVal.contains('f1') || fVal.contains('f-1') || fVal.contains('fermenter 1') || fVal.contains('fermentor 1')) {
              localFermenterIndex = 0;
            } else if (fVal.contains('2') || fVal.contains('f2') || fVal.contains('f-2') || fVal.contains('fermenter 2') || fVal.contains('fermentor 2')) {
              localFermenterIndex = 1;
            } else if (fVal.contains('3') || fVal.contains('f3') || fVal.contains('f-3') || fVal.contains('fermenter 3') || fVal.contains('fermentor 3')) {
              localFermenterIndex = 2;
            } else if (fVal.contains('4') || fVal.contains('f4') || fVal.contains('f-4') || fVal.contains('fermenter 4') || fVal.contains('fermentor 4')) {
              localFermenterIndex = 3;
            }
          }
        }

        for (int i = 1; i < table.rows.length; i++) {
          final row = table.rows[i];
          if (row.isEmpty) continue;

          double tVal = 30.0;
          double pVal = 4.5;
          double bVal = 5.0;
          double aVal = 2.0;

          if (tempCol != -1 && tempCol < row.length) {
            tVal = double.tryParse(row[tempCol]?.value?.toString() ?? '') ?? 30.0;
          }
          if (phCol != -1 && phCol < row.length) {
            pVal = double.tryParse(row[phCol]?.value?.toString() ?? '') ?? 4.5;
          }
          if (brixCol != -1 && brixCol < row.length) {
            bVal = double.tryParse(row[brixCol]?.value?.toString() ?? '') ?? 5.0;
          }
          if (alcCol != -1 && alcCol < row.length) {
            aVal = double.tryParse(row[alcCol]?.value?.toString() ?? '') ?? 2.0;
          }
          if (yeastCol != -1 && yeastCol < row.length) {
            yeastCountMillions = double.tryParse(row[yeastCol]?.value?.toString() ?? '') ?? yeastCountMillions;
          }
          if (vaCol != -1 && vaCol < row.length) {
            volatileAcidsPpm = double.tryParse(row[vaCol]?.value?.toString() ?? '') ?? volatileAcidsPpm;
          }

          tempSum += tVal;
          phSum += pVal;
          brixSum += bVal;
          rowCount++;

          if (brixList.length < 24) {
            brixList.add(bVal);
            alcList.add(aVal);
            tempList.add(tVal);
          }
        }
      } else {
        final fileInstance = File(filePath);
        final lines = await fileInstance.readAsLines();
        if (lines.isEmpty) return null;

        final headers = lines.first.toLowerCase().split(',');
        int tempCol = headers.indexWhere((h) => h.contains('temp'));
        int phCol = headers.indexWhere((h) => h.contains('ph'));
        int brixCol = headers.indexWhere((h) => h.contains('brix'));
        int alcCol = headers.indexWhere((h) => h.contains('alcohol') || h.contains('alc'));
        int yeastCol = headers.indexWhere((h) => h.contains('yeast'));
        int vaCol = headers.indexWhere((h) => h.contains('volatile') || h.contains('va'));
        int fermenterCol = headers.indexWhere((h) => h.contains('fermenter') || h.contains('fermentor') || h.contains('vessel') || h.contains('bioreactor'));

        // Extract fermenter once from the first data row (line 1)
        if (fermenterCol != -1 && lines.length > 1) {
          final parts = lines[1].split(',');
          if (fermenterCol < parts.length) {
            final fVal = parts[fermenterCol].toLowerCase();
            if (fVal.contains('1') || fVal.contains('f1') || fVal.contains('f-1') || fVal.contains('fermenter 1') || fVal.contains('fermentor 1')) {
              localFermenterIndex = 0;
            } else if (fVal.contains('2') || fVal.contains('f2') || fVal.contains('f-2') || fVal.contains('fermenter 2') || fVal.contains('fermentor 2')) {
              localFermenterIndex = 1;
            } else if (fVal.contains('3') || fVal.contains('f3') || fVal.contains('f-3') || fVal.contains('fermenter 3') || fVal.contains('fermentor 3')) {
              localFermenterIndex = 2;
            } else if (fVal.contains('4') || fVal.contains('f4') || fVal.contains('f-4') || fVal.contains('fermenter 4') || fVal.contains('fermentor 4')) {
              localFermenterIndex = 3;
            }
          }
        }

        for (int i = 1; i < lines.length; i++) {
          final parts = lines[i].split(',');
          if (parts.length < headers.length) continue;

          double tVal = 30.0;
          double pVal = 4.5;
          double bVal = 5.0;
          double aVal = 2.0;

          if (tempCol != -1) tVal = double.tryParse(parts[tempCol]) ?? 30.0;
          if (phCol != -1) pVal = double.tryParse(parts[phCol]) ?? 4.5;
          if (brixCol != -1) bVal = double.tryParse(parts[brixCol]) ?? 5.0;
          if (alcCol != -1) aVal = double.tryParse(parts[alcCol]) ?? 2.0;
          if (yeastCol != -1) yeastCountMillions = double.tryParse(parts[yeastCol]) ?? yeastCountMillions;
          if (vaCol != -1) volatileAcidsPpm = double.tryParse(parts[vaCol]) ?? volatileAcidsPpm;

          tempSum += tVal;
          phSum += pVal;
          brixSum += bVal;
          rowCount++;

          if (brixList.length < 24) {
            brixList.add(bVal);
            alcList.add(aVal);
            tempList.add(tVal);
          }
        }
      }

      if (rowCount == 0) return null;

      final double avgTemp = tempSum / rowCount;
      final double avgPh = phSum / rowCount;
      final double avgBrix = brixSum / rowCount;

      while (brixList.length < 24) {
        brixList.add(avgBrix);
        alcList.add(4.5);
        tempList.add(avgTemp);
      }

      final String flag;
      final double confidence;
      final bool recoverable;
      final List<QCEntry> actions = [];

      if (volatileAcidsPpm > 1500.0) {
        flag = 'RISK';
        confidence = 0.76;
        recoverable = false;
        actions.add(const QCEntry(action: 'Add 50 kg yeast inoculum inoculum', description: 'To restore stalling cell count.'));
        actions.add(const QCEntry(action: 'Apply cooling circulation', description: 'Mitigate temperature rise to suppress bacterial growth.'));
      } else if (avgPh < 4.4 || yeastCountMillions < 250.0) {
        flag = 'NORMAL';
        confidence = 0.84;
        recoverable = true;
        actions.add(const QCEntry(action: 'Add pH buffer adjust adjust', description: 'Correct buffer levels to optimal range (4.5 - 5.0).'));
      } else {
        flag = 'GOLDEN BATCH';
        confidence = 0.96;
        recoverable = true;
        actions.add(const QCEntry(action: 'Maintain current parameters', description: 'Batch parameters are in alignment with golden profile.'));
      }

      final List<GapTableEntry> gaps = [
        GapTableEntry(
          metric: 'Yeast Count',
          activeVal: '${yeastCountMillions.toStringAsFixed(0)} x 10^6',
          goldenVal: '300+ x 10^6',
          statusText: yeastCountMillions >= 300 ? 'Optimal' : 'Sub-optimal',
          statusColor: yeastCountMillions >= 300 ? AppColors.cyan : AppColors.amber,
        ),
        GapTableEntry(
          metric: 'Volatile Acids',
          activeVal: '${volatileAcidsPpm.toStringAsFixed(0)} ppm',
          goldenVal: '< 1500 ppm',
          statusText: volatileAcidsPpm < 1500 ? 'Optimal' : 'CRITICAL INFECTION',
          statusColor: volatileAcidsPpm < 1500 ? AppColors.cyan : AppColors.red,
        ),
        GapTableEntry(
          metric: 'pH',
          activeVal: avgPh.toStringAsFixed(2),
          goldenVal: '4.5 - 5.0',
          statusText: (avgPh >= 4.5 && avgPh <= 5.0) ? 'Optimal' : 'Sub-optimal',
          statusColor: (avgPh >= 4.5 && avgPh <= 5.0) ? AppColors.cyan : AppColors.amber,
        ),
      ];

      return ParsedBatchData(
        title: 'Attached: ${filename.length > 15 ? "${filename.substring(0, 12)}..." : filename}',
        levelFactor: 0.90,
        stateText: 'FERMENTING',
        temperature: avgTemp,
        ph: avgPh,
        brix: avgBrix,
        qualityFlag: flag,
        confidence: confidence,
        isRecoverable: recoverable,
        volatileAcidityPpm: volatileAcidsPpm,
        qcActions: actions,
        gapEntries: gaps,
        brixHistory: brixList,
        alcoholHistory: alcList,
        tempHistory: tempList,
        yeastCount: yeastCountMillions,
        fermenterIndex: localFermenterIndex,
      );
    } catch (e) {
      if (kDebugMode) print('Error parsing file locally: $e');
      return null;
    }
  }
}

