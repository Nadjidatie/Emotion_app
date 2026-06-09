import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

class ChatbotService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<String> sendMessage(
    String message,
    Map<String, dynamic> stats,
  ) async {
    final response = await supabase.functions.invoke(
      'chatbot',
      body: {
        'message': message,
        'stats': _sanitizeJson(stats),
      },
    );

    final data = _decodeIfJsonString(response.data);
    if (data == null) {
      throw Exception('Reponse vide');
    }

    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }

    if (data is Map) {
      final error = _readStringField(data, const ['error', 'message']);
      if (error != null && error.isNotEmpty) {
        throw Exception(error);
      }

      final reply = _readStringField(
        data,
        const ['reply', 'response', 'text', 'content', 'answer'],
      );
      if (reply != null && reply.isNotEmpty) {
        return reply;
      }
    }

    throw Exception('Format de reponse invalide: ${data.runtimeType}');
  }

  dynamic _decodeIfJsonString(dynamic data) {
    if (data is! String) return data;

    final trimmed = data.trim();
    if (trimmed.isEmpty) return trimmed;

    if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) {
      return trimmed;
    }

    try {
      return jsonDecode(trimmed);
    } catch (_) {
      return trimmed;
    }
  }

  String? _readStringField(Map data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  dynamic _sanitizeJson(dynamic value) {
    if (value == null || value is String || value is num || value is bool) {
      return value;
    }

    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key.toString(): _sanitizeJson(entry.value),
      };
    }

    if (value is Iterable) {
      return value.map(_sanitizeJson).toList();
    }

    return value.toString();
  }
}
