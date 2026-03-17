class UssdParser {
  /// Check if the USSD response indicates success.
  static bool isSuccess(String response) {
    final lower = response.toLowerCase();
    return lower.contains('success') ||
        lower.contains('successful') ||
        lower.contains('completed') ||
        lower.contains('submitted') ||
        lower.contains('you have bought') ||
        lower.contains('purchased');
  }

  /// Extract balance from USSD response (e.g., "New balance: Ksh 123.45").
  /// Returns null if not found.
  static double? extractBalance(String response) {
    final patterns = [
      RegExp(r'balance\D*?(\d+\.?\d*)', caseSensitive: false),
      RegExp(r'Ksh\s*(\d+\.?\d*)', caseSensitive: false),
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(response);
      if (match != null) {
        return double.tryParse(match.group(1)!);
      }
    }
    return null;
  }

  /// Parse a USSD menu response into a map of option numbers to descriptions.
  static Map<String, String> parseMenu(String response) {
    final options = <String, String>{};
    final lines = response.split('\n');
    for (final line in lines) {
      final match = RegExp(r'^(\d+)[\.:]\s*(.+)').firstMatch(line);
      if (match != null) {
        options[match.group(1)!] = match.group(2)!;
      }
    }
    return options;
  }
}