import 'dart:convert';

import 'package:budget_frontend/core/network/api_client.dart';

/// Service for calling `POST /api/smart-add`.
///
/// Reads a bill photo, PDF, voice note or typed text into entries.
class SmartAddService {
  SmartAddService(this.client);

  final ApiClient client;

  String _formatToday(DateTime now) {
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Reads typed text or voice transcription via `POST /api/smart-add`.
  ///
  /// [inputType] must be 'text' or 'voice'.
  Future<String> smartAddText({
    required String text,
    String inputType = 'text',
  }) async {
    final now = DateTime.now();
    final today = _formatToday(now);
    final tzOffsetMinutes = now.timeZoneOffset.inMinutes;

    final res = await client.postFull('/smart-add', {
      'inputType': inputType,
      'text': text.trim(),
      'today': today,
      'tzOffsetMinutes': tzOffsetMinutes,
    });

    return res['message'] as String? ?? 'Transactions added';
  }

  /// Reads a photo or PDF file via `POST /api/smart-add`.
  ///
  /// [inputType] must be 'image' or 'pdf'.
  /// [mimeType] e.g. 'image/jpeg', 'image/png', 'application/pdf'.
  /// [bytes] file content bytes (encoded as base64 string).
  Future<String> smartAddFile({
    required List<int> bytes,
    required String mimeType,
    required String inputType,
  }) async {
    final now = DateTime.now();
    final today = _formatToday(now);
    final tzOffsetMinutes = now.timeZoneOffset.inMinutes;

    final base64String = base64Encode(bytes);

    final res = await client.postFull('/smart-add', {
      'inputType': inputType,
      'file': {
        'mimeType': mimeType,
        'data': base64String,
      },
      'today': today,
      'tzOffsetMinutes': tzOffsetMinutes,
    });

    return res['message'] as String? ?? 'Transactions added';
  }
}
