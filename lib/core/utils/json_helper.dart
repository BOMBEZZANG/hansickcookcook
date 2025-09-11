import 'dart:convert';

/// Helper utilities for JSON operations
class JsonHelper {
  /// Safely decode JSON string with error handling
  static Map<String, dynamic>? safeDecodeMap(String jsonString) {
    try {
      final decoded = json.decode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Safely decode JSON string to List
  static List<dynamic>? safeDecodeList(String jsonString) {
    try {
      final decoded = json.decode(jsonString);
      if (decoded is List) {
        return decoded;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Safely encode object to JSON string
  static String? safeEncode(dynamic object) {
    try {
      return json.encode(object);
    } catch (e) {
      return null;
    }
  }
  
  /// Pretty print JSON with indentation
  static String prettyPrint(dynamic object) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(object);
    } catch (e) {
      return object.toString();
    }
  }
}