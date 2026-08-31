import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../utils/file_uploader_util.dart';

class DatabaseSyncService {
  // TODO: Replace this base URL with your remote database API endpoint when ready.
  // Example: 'http://192.168.1.100:8000' or 'https://api.yourcompany.com'
  final String _baseUrl = 'http://127.0.0.1:8000';

  /// Sends the parsed batch prediction metrics to the remote REST API to store in the database.
  Future<bool> syncPredictionToDatabase(ParsedBatchData data) async {
    final String endpoint = '$_baseUrl/api/predictions';
    
    // Construct database schema JSON payload
    final Map<String, dynamic> payload = {
      'batch_title': data.title,
      'level_factor': data.levelFactor,
      'state_text': data.stateText,
      'temperature': data.temperature,
      'ph': data.ph,
      'brix': data.brix,
      'quality_flag': data.qualityFlag,
      'confidence': data.confidence,
      'is_recoverable': data.isRecoverable,
      'volatile_acidity_ppm': data.volatileAcidityPpm,
      'yeast_count_million': data.yeastCount,
      'brix_history': data.brixHistory,
      'alcohol_history': data.alcoholHistory,
      'temp_history': data.tempHistory,
      'qc_suggestions': data.qcActions.map((e) => e.action).toList(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      debugPrint('[SyncService] Initiating upload to database endpoint: $endpoint');
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer YOUR_TOKEN_HERE', // Add authorization header if required
        },
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[SyncService] Sync successful! Database Response Status: ${response.statusCode}');
        return true;
      } else {
        debugPrint('[SyncService] Sync failed! Server responded with status: ${response.statusCode}');
        debugPrint('[SyncService] Response body: ${response.body}');
        return false;
      }
    } catch (error) {
      debugPrint('[SyncService] Error during REST API request execution: $error');
      return false;
    }
  }
}
