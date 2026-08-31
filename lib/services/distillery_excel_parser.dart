import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'package:flutter/foundation.dart';

/// Single parsed and validated row from an Excel spreadsheet for PreprocessingData.
class ParsedExcelRow {
  final DateTime? timestampMinute;
  final DateTime? serverTimestamp;

  // Process / AI features
  final double? sugarConsumptionRate;
  final double? feedingHours;
  final double? retentionHours;
  final double? setupSg;
  final double? finalSg;
  final double? sgDifference;
  final double? alcoholSetup;
  final double? alcoholFinal;
  final double? phSetup;
  final double? phFinal;
  final double? rawSpentWashBrix;
  final double? bottomSpentWashBrix;
  final double? ffeOutletSpentWashBrix;
  final double? concentratedSpentWashBrix;

  // Context variables
  final double? temperature;
  final double? brix;
  final double? residualSugar;
  final double? yeastActivity;
  final double? volatileAcidity;
  final double? coolingValve;
  final double? agitatorRpm;
  final double? steamValve;
  final double? tankLevelPercent;
  final double? tankWeightKg;
  final double? co2FlowKgph;
  final double? headspacePressureBar;

  // Row-level batch context if present
  final String? batchId;
  final String? fermenter;
  final String? state;

  const ParsedExcelRow({
    this.timestampMinute,
    this.serverTimestamp,
    this.sugarConsumptionRate,
    this.feedingHours,
    this.retentionHours,
    this.setupSg,
    this.finalSg,
    this.sgDifference,
    this.alcoholSetup,
    this.alcoholFinal,
    this.phSetup,
    this.phFinal,
    this.rawSpentWashBrix,
    this.bottomSpentWashBrix,
    this.ffeOutletSpentWashBrix,
    this.concentratedSpentWashBrix,
    this.temperature,
    this.brix,
    this.residualSugar,
    this.yeastActivity,
    this.volatileAcidity,
    this.coolingValve,
    this.agitatorRpm,
    this.steamValve,
    this.tankLevelPercent,
    this.tankWeightKg,
    this.co2FlowKgph,
    this.headspacePressureBar,
    this.batchId,
    this.fermenter,
    this.state,
  });
}

/// Overall result of parsing an Excel workbook.
class ParsedExcelWorkbook {
  final String sheetName;
  final int totalRowsScanned;
  final int validRowsCount;
  final int skippedRowsCount;
  final String batchId;
  final String? fermenter;
  final String? state;
  final DateTime? batchStartTime;
  final DateTime? batchEndTime;
  final List<ParsedExcelRow> rows;
  final Map<String, String> detectedColumns;

  const ParsedExcelWorkbook({
    required this.sheetName,
    required this.totalRowsScanned,
    required this.validRowsCount,
    required this.skippedRowsCount,
    required this.batchId,
    this.fermenter,
    this.state,
    this.batchStartTime,
    this.batchEndTime,
    required this.rows,
    required this.detectedColumns,
  });
}

/// Robust Flutter/Dart Excel parser with coordinate-aligned multi-row hierarchical schema mapping.
class DistilleryExcelParser {
  /// Converts Excel column letters (A, B, Z, AA, AB...) into a 0-indexed column integer.
  static int columnLetterToIndex(String colLetter) {
    int result = 0;
    final upper = colLetter.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    for (int i = 0; i < upper.length; i++) {
      result = result * 26 + (upper.codeUnitAt(i) - 64);
    }
    return result > 0 ? result - 1 : 0;
  }

  /// Normalizes header string for alias matching (lowercase, removes symbols, spaces, and punctuation).
  static String normalizeHeader(String raw) {
    return raw
        .toLowerCase()
        .replaceAll(RegExp(r'[\(\)\[\]\{\}\%\Â°\/\-\_\.\,\:\#]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static bool _hasPhrase(String text, List<String> phrases) {
    for (final p in phrases) {
      if (RegExp(r'\b' + RegExp.escape(p) + r'\b').hasMatch(text)) {
        return true;
      }
    }
    return false;
  }

  /// Parses an Excel file from disk.
  static Future<ParsedExcelWorkbook> parseFile(File file, {String defaultBatchPrefix = 'BATCH'}) async {
    if (!await file.exists()) {
      throw FormatException('Excel file does not exist: ${file.path}');
    }

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw const FormatException('Downloaded Excel file is empty (0 bytes).');
    }

    return parseBytes(bytes, fileName: file.uri.pathSegments.last, defaultBatchPrefix: defaultBatchPrefix);
  }

  /// Parses Excel workbook bytes directly using hierarchical multi-row header mapping.
  static ParsedExcelWorkbook parseBytes(
    Uint8List bytes, {
    String fileName = 'file.xlsx',
    String defaultBatchPrefix = 'BATCH',
  }) {
    List<List<dynamic>> grid;
    String sheetName = 'Sheet1';

    try {
      final extraction = _extractGridFromXlsx(bytes);
      grid = extraction.grid;
      sheetName = extraction.sheetName;
    } catch (e) {
      debugPrint('[DistilleryExcelParser] Direct XML extraction fallback: $e');
      grid = _fallbackPackageExcelGrid(bytes);
    }

    if (grid.isEmpty) {
      throw const FormatException('Excel workbook has 0 data rows.');
    }

    // 1. Locate the Main Header Row (search first 15 rows for distillery column keywords)
    int mainHeaderRowIndex = -1;
    int maxKeywordCount = 0;

    for (int r = 0; r < grid.length && r < 15; r++) {
      final row = grid[r];
      int headerKeywords = 0;
      for (final cell in row) {
        if (cell == null) continue;
        final s = cell.toString().toLowerCase().trim();
        if (s == 'date' || s == 'timestamp' || s == 'batch id' || s == 'fermenter number' ||
            s.startsWith('feeding hour') || s.startsWith('retention hour') ||
            s == 'setup' || s == 'final' || s == 'difference' ||
            s == 'ph' || s == 'brix' || s == 'temperature' || s == 'cell count' ||
            s == 'trs' || s == 'va' || s == 'bx' || s == 'sg' || s == 'alert') {
          headerKeywords++;
        }
      }
      if (headerKeywords >= 2 && headerKeywords > maxKeywordCount) {
        maxKeywordCount = headerKeywords;
        mainHeaderRowIndex = r;
      }
    }

    if (mainHeaderRowIndex == -1) {
      mainHeaderRowIndex = 0;
    }

    final int firstDataRowIndex = mainHeaderRowIndex + 1;

    // 2. Build Multi-Row Header Map for every column
    final int maxCols = grid.map((r) => r.length).fold(0, (max, len) => len > max ? len : max);
    final Map<int, String> columnIndexToField = {};
    final Map<String, String> detectedColumns = {};

    if (mainHeaderRowIndex <= 0) {
      // Single-row header (Row 0)
      final headerRow = grid[0];
      for (int c = 0; c < headerRow.length; c++) {
        final cellStr = headerRow[c]?.toString().trim() ?? '';
        if (cellStr.isNotEmpty) {
          final field = _mapHeaderToField(cellStr);
          if (field != null) {
            columnIndexToField[c] = field;
            detectedColumns[cellStr] = field;
          }
        }
      }
    } else {
      // Multi-row hierarchical header (Rows 0 to mainHeaderRowIndex)
      final mainHeaderRow = grid[mainHeaderRowIndex];
      String activeGroup = '';

      for (int c = 0; c < maxCols; c++) {
        // Look up group headers in rows above mainHeaderRowIndex for this column
        for (int r = 0; r < mainHeaderRowIndex; r++) {
          if (c < grid[r].length && grid[r][c] != null) {
            final cellStr = grid[r][c].toString().trim();
            if (cellStr.isNotEmpty && _isGroupHeader(cellStr)) {
              activeGroup = cellStr;
            }
          }
        }

        final subStr = (c < mainHeaderRow.length && mainHeaderRow[c] != null) ? mainHeaderRow[c].toString().trim() : '';

        String combinedHeader;
        if (_isGenericSubHeader(subStr) && activeGroup.isNotEmpty) {
          combinedHeader = '$activeGroup $subStr';
        } else if (subStr.isNotEmpty) {
          combinedHeader = subStr;
        } else if (activeGroup.isNotEmpty) {
          combinedHeader = activeGroup;
        } else {
          continue;
        }

        final field = _mapHeaderToField(combinedHeader);
        if (field != null) {
          columnIndexToField[c] = field;
          detectedColumns[combinedHeader] = field;
        }
      }
    }

    debugPrint('[DistilleryExcelParser] Sheet: $sheetName | First Data Row: $firstDataRowIndex | Mapped ${columnIndexToField.length} columns: $detectedColumns');

    // 3. Extract Data Rows
    final List<ParsedExcelRow> parsedRows = [];
    int skippedCount = 0;
    String? inferredBatchId;
    String? inferredFermenter;
    String? inferredState;
    DateTime? firstTimestamp;
    DateTime? lastTimestamp;

    for (int r = firstDataRowIndex; r < grid.length; r++) {
      final row = grid[r];
      if (row.isEmpty) {
        skippedCount++;
        continue;
      }

      final rowData = <String, dynamic>{};
      bool hasAnyValue = false;

      for (int c = 0; c < row.length; c++) {
        final field = columnIndexToField[c];
        final cellVal = row[c];
        if (cellVal == null || cellVal.toString().trim().isEmpty) continue;

        hasAnyValue = true;

        if (field != null) {
          rowData[field] = cellVal;
        } else {
          rowData['col_$c'] = cellVal;
        }
      }

      if (!hasAnyValue) {
        skippedCount++;
        continue;
      }

      final parsedRow = _buildParsedRow(rowData);
      if (parsedRow != null) {
        parsedRows.add(parsedRow);

        if (parsedRow.timestampMinute != null) {
          firstTimestamp ??= parsedRow.timestampMinute;
          lastTimestamp = parsedRow.timestampMinute;
        }

        if (inferredBatchId == null && parsedRow.batchId != null && parsedRow.batchId!.isNotEmpty) {
          inferredBatchId = parsedRow.batchId;
        }
        if (inferredFermenter == null && parsedRow.fermenter != null) {
          inferredFermenter = parsedRow.fermenter;
        }
        if (inferredState == null && parsedRow.state != null) {
          inferredState = parsedRow.state;
        }
      } else {
        skippedCount++;
      }
    }

    if (parsedRows.isEmpty) {
      throw const FormatException('No valid process data rows found in Excel sheet.');
    }

    // Infer Batch ID from file name if not present in rows (e.g. 1.xlsx -> BATCH-01)
    if (inferredBatchId == null || inferredBatchId.isEmpty) {
      final cleanBase = fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '').trim();
      final numMatch = RegExp(r'\d+').firstMatch(cleanBase);
      if (numMatch != null) {
        final padded = numMatch.group(0)!.padLeft(2, '0');
        inferredBatchId = '$defaultBatchPrefix-$padded';
      } else {
        inferredBatchId = '$defaultBatchPrefix-$cleanBase';
      }
    }

    return ParsedExcelWorkbook(
      sheetName: sheetName,
      totalRowsScanned: grid.length,
      validRowsCount: parsedRows.length,
      skippedRowsCount: skippedCount,
      batchId: inferredBatchId,
      fermenter: inferredFermenter,
      state: inferredState ?? 'ACTIVE',
      batchStartTime: firstTimestamp,
      batchEndTime: lastTimestamp,
      rows: parsedRows,
      detectedColumns: detectedColumns,
    );
  }

  static bool _isGroupHeader(String raw) {
    final h = normalizeHeader(raw);
    return h.contains('specific gravity') ||
        h.contains('alcohol') ||
        h.contains('residual sugar') ||
        h.contains('ph') ||
        h.contains('va ppm') ||
        h.contains('spent wash') ||
        h.contains('steam') ||
        h.contains('molasses');
  }

  static bool _isGenericSubHeader(String raw) {
    final h = normalizeHeader(raw);
    return h == 'setup' ||
        h == 'final' ||
        h == 'difference' ||
        h == 'diff' ||
        h == 'initial' ||
        h == 'start' ||
        h == 'end';
  }

  /// Comprehensive mapping of distillery parameter headers to PreprocessingData / Batch entity fields.
  static String? _mapHeaderToField(String rawHeader) {
    final h = normalizeHeader(rawHeader);

    // 1. Timestamp / Date / Time
    if (_hasPhrase(h, ['timestamp', 'date time', 'datetime', 'sample time', 'sample date', 'record time', 'log time'])) {
      return 'timestampMinute';
    }
    if (h == 'time' || h == 'date' || h == 'datetime' || h == 'timestamp' || h == 'hour') {
      return 'timestampMinute';
    }

    // 2. Batch ID / Fermenter Number
    if (_hasPhrase(h, ['fermenter number', 'fermenter no', 'batch id', 'batch no', 'batch number', 'lot', 'lot id'])) {
      return 'batchId';
    }

    // 3. Fermenter / Vessel / Tank / PF
    if (_hasPhrase(h, ['fermenter', 'fermentor', 'vessel', 'tank no', 'tank number', 'pf'])) {
      return 'fermenter';
    }

    // 4. State / Status / ALERT
    if (_hasPhrase(h, ['alert', 'state', 'stage', 'phase', 'status', 'condition'])) {
      return 'state';
    }

    // 5. Feeding Hours & Retention Hours
    if (_hasPhrase(h, ['feeding hours', 'feed hours', 'feeding duration', 'feed duration', 'feed time', 'feeding time', 'feeding hr', 'feed hr'])) {
      return 'feedingHours';
    }
    if (_hasPhrase(h, ['retention hours', 'retention hour', 'retention duration', 'hold duration', 'hold time', 'retention time', 'retention hr'])) {
      return 'retentionHours';
    }

    // 6. Specific Gravity (Setup / Final / Diff) - Must have SG or Specific Gravity
    if (h.contains('specific gravity') || h.contains('sg')) {
      if (_hasPhrase(h, ['setup', 'initial', 'start'])) return 'setupSg';
      if (_hasPhrase(h, ['final', 'ending', 'end', 'last'])) return 'finalSg';
      if (_hasPhrase(h, ['difference', 'diff', 'delta'])) return 'sgDifference';
    }

    // 7. Alcohol Setup / Final / % - Must have Alcohol or Alc or Ethanol
    if (h.contains('alcohol') || h.contains('ethanol') || h.contains('alc')) {
      if (_hasPhrase(h, ['setup', 'initial', 'start'])) return 'alcoholSetup';
      if (_hasPhrase(h, ['final', 'ending', 'end', 'loss'])) return 'alcoholFinal';
      if (h == 'alcohol' || h == 'ethanol' || h == 'alc') return 'alcoholFinal';
    }

    // 8. Residual Sugar (Setup / Final / TRS / RS / Reducing Sugar)
    if (h.contains('residual sugar') || h.contains('rs') || h.contains('trs') || h.contains('reducing sugar')) {
      if (_hasPhrase(h, ['final', 'ending', 'end', 'trs', 'residual sugar', 'reducing sugar', 'rs feed'])) return 'residualSugar';
    }

    // 9. Sugar Consumption Rate
    if (_hasPhrase(h, ['sugar consumption', 'sugar consumption rate', 'sugar rate', 'consumption rate', 'rate of sugar', 'scr', 'sugar uptake'])) {
      return 'sugarConsumptionRate';
    }

    // 10. pH Setup / Final - Must have pH
    if (h.contains('ph')) {
      if (_hasPhrase(h, ['setup', 'initial', 'start'])) return 'phSetup';
      if (_hasPhrase(h, ['final', 'ending', 'end', 'fermenter ph'])) return 'phFinal';
      if (h == 'ph') return 'phFinal';
    }

    // 11. Volatile Acidity (Setup / Final / VA) - Must have VA or Volatile Acidity
    if (h.contains('va') || h.contains('volatile acidity') || h.contains('total acidity')) {
      if (_hasPhrase(h, ['setup', 'initial', 'start'])) return null;
      if (_hasPhrase(h, ['final', 'ending', 'end'])) return 'volatileAcidity';
      if (h == 'va ppm final' || h == 'va final' || h == 'volatile acidity' || h == 'va') return 'volatileAcidity';
    }

    // 12. Spent Wash Brix (Conc / Bottom / Raw / FFE)
    if (_hasPhrase(h, ['conc spent wash brix', 'conc spent wash', 'concentrated spent wash brix', 'csw brix', 'spent was brix'])) {
      return 'concentratedSpentWashBrix';
    }
    if (_hasPhrase(h, ['analyser bottom spentwash brix', 'bottom spent wash brix', 'bottom wash brix', 'bsw brix', 'analyser bottom'])) {
      return 'bottomSpentWashBrix';
    }
    if (_hasPhrase(h, ['raw spent wash brix', 'raw spent wash', 'raw wash brix', 'rsw brix'])) {
      return 'rawSpentWashBrix';
    }
    if (_hasPhrase(h, ['ffe outlet spent wash brix', 'ffe outlet', 'ffe brix', 'ffe outlet brix'])) {
      return 'ffeOutletSpentWashBrix';
    }

    // 13. Brix / BX
    if (_hasPhrase(h, ['bx', 'analyser fermented wash feed brix', 'wort brix', 'wash brix', 'feed brix', 'brix', 'fs'])) {
      return 'brix';
    }

    // 14. Yeast Activity / Cell Count
    if (_hasPhrase(h, ['cell count', 'yeast count', 'yeast viability', 'viability', 'yeast activity', 'yeast'])) {
      return 'yeastActivity';
    }

    // 15. Temperature
    if (_hasPhrase(h, ['temp', 'temperature', 'fermenter temp', 'broth temp', 'wash temp', 'temp c', 'temperature c'])) {
      return 'temperature';
    }

    // 16. Valves / Actuators
    if (_hasPhrase(h, ['cooling valve', 'cooling water valve', 'cw valve', 'cooling water', 'cooling'])) {
      return 'coolingValve';
    }
    if (_hasPhrase(h, ['agitator', 'agitator rpm', 'agitator speed', 'mixer', 'mixer rpm', 'rpm'])) {
      return 'agitatorRpm';
    }
    if (_hasPhrase(h, ['steam valve', 'steam flow', 'steam', 'heating valve'])) {
      return 'steamValve';
    }

    // 17. Level / Weight / Volume
    if (_hasPhrase(h, ['tank level', 'liquid level', 'level percent', 'level'])) {
      return 'tankLevelPercent';
    }
    if (_hasPhrase(h, ['fermenter volume', 'tank weight', 'weight kg', 'mass kg', 'tank mass', 'weight'])) {
      return 'tankWeightKg';
    }

    // 18. CO2 Flow & Pressure
    if (_hasPhrase(h, ['co2 flow', 'co2 rate', 'co2 gas', 'co2 kgph', 'co2'])) {
      return 'co2FlowKgph';
    }
    if (_hasPhrase(h, ['headspace pressure', 'tank pressure', 'pressure bar', 'pressure'])) {
      return 'headspacePressureBar';
    }

    return null;
  }

  /// Extracts rows directly from raw .xlsx XML preserving exact column index coordinates for each cell.
  static ({List<List<dynamic>> grid, String sheetName}) _extractGridFromXlsx(Uint8List bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);

    // 1. Read shared strings
    final sharedStrings = <String>[];
    final sharedStringsFile = archive.findFile('xl/sharedStrings.xml');
    if (sharedStringsFile != null) {
      final xmlStr = utf8.decode(sharedStringsFile.content as List<int>, allowMalformed: true);
      final siMatches = RegExp(r'<si>(.*?)</si>', dotAll: true).allMatches(xmlStr);
      for (final sm in siMatches) {
        final siContent = sm.group(1) ?? '';
        final tMatches = RegExp(r'<t[^>]*>(.*?)</t>', dotAll: true).allMatches(siContent);
        final fullStr = tMatches.map((m) => m.group(1) ?? '').join();
        sharedStrings.add(fullStr);
      }
    }

    // 2. Find first worksheet
    final sheetFile = archive.files.firstWhere(
      (f) => f.name.startsWith('xl/worksheets/sheet') && f.name.endsWith('.xml'),
      orElse: () => throw const FormatException('No worksheet XML found in .xlsx archive.'),
    );

    final sheetName = sheetFile.name.replaceAll('xl/worksheets/', '').replaceAll('.xml', '');
    final sheetXml = utf8.decode(sheetFile.content as List<int>, allowMalformed: true);
    final List<List<dynamic>> rows = [];

    final rowMatches = RegExp(r'<row[^>]*>(.*?)</row>', dotAll: true).allMatches(sheetXml);
    for (final rm in rowMatches) {
      final rowContent = rm.group(1) ?? '';
      final cellMatches = RegExp(r'<c\s+([^>]*?)>(.*?)</c>|<c\s+([^>]*?)/>', dotAll: true).allMatches(rowContent);
      
      final Map<int, dynamic> rowCellMap = {};
      int maxColIndex = -1;

      for (final cm in cellMatches) {
        final attrStr = cm.group(1) ?? cm.group(3) ?? '';
        final bodyStr = cm.group(2) ?? '';

        final rMatch = RegExp(r'r="([A-Za-z]+)\d+"').firstMatch(attrStr);
        int colIdx;
        if (rMatch != null) {
          colIdx = columnLetterToIndex(rMatch.group(1)!);
        } else {
          colIdx = maxColIndex + 1;
        }

        if (colIdx > maxColIndex) maxColIndex = colIdx;

        final isString = attrStr.contains('t="s"');
        final isInlineString = attrStr.contains('t="inlineStr"');
        final valMatch = RegExp(r'<v>(.*?)</v>').firstMatch(bodyStr);

        dynamic cellVal;
        if (valMatch != null) {
          final valText = valMatch.group(1) ?? '';
          if (isString) {
            final idx = int.tryParse(valText);
            if (idx != null && idx >= 0 && idx < sharedStrings.length) {
              cellVal = sharedStrings[idx];
            } else {
              cellVal = valText;
            }
          } else {
            final numVal = double.tryParse(valText);
            cellVal = numVal ?? valText;
          }
        } else if (isInlineString || bodyStr.contains('<t>')) {
          final inlineMatch = RegExp(r'<t[^>]*>(.*?)</t>').firstMatch(bodyStr);
          cellVal = inlineMatch?.group(1);
        }

        if (cellVal != null) {
          rowCellMap[colIdx] = cellVal;
        }
      }

      if (rowCellMap.isNotEmpty) {
        final rowList = List<dynamic>.filled(maxColIndex + 1, null, growable: true);
        for (final entry in rowCellMap.entries) {
          rowList[entry.key] = entry.value;
        }
        rows.add(rowList);
      }
    }

    return (grid: rows, sheetName: sheetName);
  }

  /// Fallback extraction using spreadsheet_decoder
  static List<List<dynamic>> _fallbackPackageExcelGrid(Uint8List bytes) {
    try {
      final decoder = SpreadsheetDecoder.decodeBytes(bytes, update: false);
      if (decoder.tables.isEmpty) return [];
      final sheet = decoder.tables.values.firstWhere(
        (s) => s.rows.isNotEmpty,
        orElse: () => decoder.tables.values.first,
      );
      return sheet.rows;
    } catch (e) {
      return [];
    }
  }

  /// Converts a map of row values into a typed ParsedExcelRow.
  static ParsedExcelRow? _buildParsedRow(Map<String, dynamic> rowData) {
    DateTime? timestamp = _parseDateTime(rowData['timestampMinute']);
    double? temp = _parseDouble(rowData['temperature']);
    double? brix = _parseDouble(rowData['brix']);
    double? rs = _parseDouble(rowData['residualSugar']);
    double? rate = _parseDouble(rowData['sugarConsumptionRate']);

    final hasMetrics = temp != null || brix != null || rs != null || rate != null ||
        rowData['setupSg'] != null || rowData['finalSg'] != null || rowData['alcoholFinal'] != null ||
        rowData['alcoholSetup'] != null || rowData['phFinal'] != null || rowData['phSetup'] != null ||
        rowData['feedingHours'] != null || rowData['retentionHours'] != null ||
        rowData['rawSpentWashBrix'] != null || rowData['bottomSpentWashBrix'] != null ||
        rowData['concentratedSpentWashBrix'] != null || rowData['ffeOutletSpentWashBrix'] != null ||
        rowData['volatileAcidity'] != null || rowData['yeastActivity'] != null;

    if (!hasMetrics && timestamp == null) {
      return null;
    }

    return ParsedExcelRow(
      timestampMinute: timestamp,
      serverTimestamp: _parseDateTime(rowData['serverTimestamp']) ?? DateTime.now(),
      temperature: temp,
      brix: brix,
      residualSugar: rs,
      sugarConsumptionRate: rate,
      feedingHours: _parseDouble(rowData['feedingHours']),
      retentionHours: _parseDouble(rowData['retentionHours']),
      setupSg: _parseDouble(rowData['setupSg']),
      finalSg: _parseDouble(rowData['finalSg']),
      sgDifference: _parseDouble(rowData['sgDifference']),
      alcoholSetup: _parseDouble(rowData['alcoholSetup']),
      alcoholFinal: _parseDouble(rowData['alcoholFinal']),
      phSetup: _parseDouble(rowData['phSetup']),
      phFinal: _parseDouble(rowData['phFinal']),
      rawSpentWashBrix: _parseDouble(rowData['rawSpentWashBrix']),
      bottomSpentWashBrix: _parseDouble(rowData['bottomSpentWashBrix']),
      ffeOutletSpentWashBrix: _parseDouble(rowData['ffeOutletSpentWashBrix']),
      concentratedSpentWashBrix: _parseDouble(rowData['concentratedSpentWashBrix']),
      yeastActivity: _parseDouble(rowData['yeastActivity']),
      volatileAcidity: _parseDouble(rowData['volatileAcidity']),
      coolingValve: _parseDouble(rowData['coolingValve']),
      agitatorRpm: _parseDouble(rowData['agitatorRpm']),
      steamValve: _parseDouble(rowData['steamValve']),
      tankLevelPercent: _parseDouble(rowData['tankLevelPercent']),
      tankWeightKg: _parseDouble(rowData['tankWeightKg']),
      co2FlowKgph: _parseDouble(rowData['co2FlowKgph']),
      headspacePressureBar: _parseDouble(rowData['headspacePressureBar']),
      batchId: rowData['batchId']?.toString(),
      fermenter: rowData['fermenter']?.toString(),
      state: rowData['state']?.toString(),
    );
  }

  static double? _parseDouble(dynamic val) {
    if (val == null) return null;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is num) return val.toDouble();
    final str = val.toString().trim().replaceAll('%', '').replaceAll(',', '.');
    if (str.isEmpty || str == '-' || str == 'N/A' || str == 'null' || str.startsWith('=')) return null;
    return double.tryParse(str);
  }

  static DateTime? _parseDateTime(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;
    final str = val.toString().trim();
    if (str.isEmpty || str == '-' || str == 'null' || str.startsWith('=')) return null;
    return _parseDateString(str);
  }

  static DateTime? _parseDateString(String str) {
    final direct = DateTime.tryParse(str);
    if (direct != null) return direct;

    // Handle MM-DD-YYYY or DD-MM-YYYY (e.g. "07-16-2026")
    final match = RegExp(r'^(\d{1,2})[\-\/\.](\d{1,2})[\-\/\.](\d{2,4})').firstMatch(str);
    if (match != null) {
      int p1 = int.parse(match.group(1)!);
      int p2 = int.parse(match.group(2)!);
      int year = int.parse(match.group(3)!);
      if (year < 100) year += 2000;

      // Check if p1 is month (<=12) or day
      int month = p1;
      int day = p2;
      if (p1 > 12 && p2 <= 12) {
        day = p1;
        month = p2;
      }
      return DateTime.utc(year, month, day);
    }
    return null;
  }
}

