class ParsedVoiceEntry {
  final double amount;
  final String note;
  final String category;
  final String transactionType; // 'Spend' or 'Income'

  const ParsedVoiceEntry({
    required this.amount,
    required this.note,
    required this.category,
    required this.transactionType,
  });
}

/// Natural language and regex parsing utilities for voice-transcribed financial notes.
class VoiceTextParser {
  VoiceTextParser._();

  /// Parses multiple voice entries if the utterance contains multiple items
  /// (e.g. "lunch 250 and Uber 120" -> [Lunch: 250, Uber: 120]).
  static List<ParsedVoiceEntry> parseEntries(String rawText) {
    if (rawText.trim().isEmpty) return [];

    // 1. Try splitting on conjunctions, commas or newlines
    final segments = rawText
        .split(RegExp(r'\s+(?:and|&|\+)\s+|,\s*|\n+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (segments.length > 1) {
      final List<ParsedVoiceEntry> parsedItems = [];
      for (final seg in segments) {
        final amt = parseAmount(seg);
        if (amt != null && amt > 0) {
          parsedItems.add(parseEntry(seg, amt));
        }
      }
      if (parsedItems.isNotEmpty) {
        return parsedItems;
      }
    }

    // 2. Single entry fallback
    final singleAmount = parseAmount(rawText);
    if (singleAmount != null && singleAmount > 0) {
      return [parseEntry(rawText, singleAmount)];
    }

    return [];
  }

  /// Extracts the monetary amount from raw transcribed voice or typed text.
  static double? parseAmount(String rawText) {
    if (rawText.trim().isEmpty) return null;

    final lower = rawText.toLowerCase();

    // 1. Explicit currency patterns (e.g. ₹250, rs 250, 250 rs, 250 rupees, $50)
    final explicitCurrencyReg = RegExp(
      r'(?:(?:₹|rs\.?|inr|\$)\s*(\d+(?:\.\d+)?))|(?:(\d+(?:\.\d+)?)\s*(?:rs\.?|rupees|inr|bucks|dollars))',
    );
    final explicitMatches = explicitCurrencyReg.allMatches(lower);
    if (explicitMatches.isNotEmpty) {
      double total = 0.0;
      for (final m in explicitMatches) {
        final valStr = m.group(1) ?? m.group(2);
        if (valStr != null) {
          total += double.tryParse(valStr) ?? 0.0;
        }
      }
      if (total > 0) return total;
    }

    // 2. Strip out non-amount contextual numbers
    String cleaned = lower;

    // Ordinal dates/numbers: 1st, 2nd, 3rd, 4th, 15th, etc.
    cleaned = cleaned.replaceAll(RegExp(r'\b\d+(?:st|nd|rd|th)\b'), ' ');

    // Calendar years: 2020-2029
    cleaned = cleaned.replaceAll(RegExp(r'\b202\d\b'), ' ');

    // Context words with numbers: table 4, room 101, seat 12, gate 5, order 123, flight 402, etc.
    cleaned = cleaned.replaceAll(
      RegExp(
        r'\b(?:table|room|seat|gate|flat|order|id|bus|train|flight|platform|no|number)\s*#?\s*\d+\b',
      ),
      ' ',
    );

    // Quantities with units: 2 kg, 5 km, 3 hrs, 10 pcs, etc.
    cleaned = cleaned.replaceAll(
      RegExp(
        r'\b\d+\s*(?:items?|pcs|pieces?|qty|kg|kgs|km|kms|hours?|hrs|mins?|minutes?|%|percent)\b',
      ),
      ' ',
    );

    // Quantities before common counted items: "2 pizzas", "3 coffees", "4 beers", "2 plates", "5 tickets"
    cleaned = cleaned.replaceAll(
      RegExp(
        r'\b\d+\s+(?:pizzas?|burgers?|coffees?|beers?|plates?|bottles?|tickets?|cups?|drinks?|cans?|packs?|people|persons?)\b',
      ),
      ' ',
    );

    // 3. Look for numbers preceded by payment / cost prepositions (e.g. "for 250", "paid 500", "spent 120", "was 180")
    final paymentLeadReg = RegExp(
      r'(?:for|paid|spent|cost|price|bill|was|amount)\s+(\d+(?:\.\d+)?)',
    );
    final paymentMatches = paymentLeadReg.allMatches(cleaned);
    if (paymentMatches.isNotEmpty) {
      double total = 0.0;
      for (final m in paymentMatches) {
        final val = double.tryParse(m.group(1) ?? '0') ?? 0.0;
        total += val;
      }
      if (total > 0) return total;
    }

    // 4. Standalone numbers remaining in the cleaned text
    final numReg = RegExp(r'\b\d+(?:\.\d+)?\b');
    final matches = numReg.allMatches(cleaned).toList();

    if (matches.isNotEmpty) {
      // Sum only if numbers are explicitly linked with "and", "&", or "+"
      if (matches.length > 1 &&
          (cleaned.contains(' and ') ||
              cleaned.contains(' & ') ||
              cleaned.contains(' + '))) {
        double total = 0.0;
        for (final m in matches) {
          total += double.tryParse(m.group(0) ?? '0') ?? 0.0;
        }
        if (total > 0) return total;
      }

      // Single remaining number is the amount
      if (matches.length == 1) {
        final val = double.tryParse(matches.first.group(0) ?? '0');
        if (val != null && val > 0) return val;
      }

      // If multiple numbers without "and", prefer the largest/final monetary amount
      double maxVal = 0.0;
      for (final m in matches) {
        final val = double.tryParse(m.group(0) ?? '0') ?? 0.0;
        if (val > maxVal) maxVal = val;
      }
      if (maxVal > 0) return maxVal;
    }

    // 5. Fallback: simple English number words
    const wordMap = {
      'one': 1.0,
      'two': 2.0,
      'three': 3.0,
      'four': 4.0,
      'five': 5.0,
      'six': 6.0,
      'seven': 7.0,
      'eight': 8.0,
      'nine': 9.0,
      'ten': 10.0,
      'twenty': 20.0,
      'thirty': 30.0,
      'forty': 40.0,
      'fifty': 50.0,
      'sixty': 60.0,
      'seventy': 70.0,
      'eighty': 80.0,
      'ninety': 90.0,
      'hundred': 100.0,
      'thousand': 1000.0,
    };
    final words = cleaned.split(RegExp(r'\s+'));
    double wordTotal = 0.0;
    for (final w in words) {
      if (wordMap.containsKey(w)) {
        wordTotal += wordMap[w]!;
      }
    }
    return wordTotal > 0 ? wordTotal : null;
  }

  /// Parses category, clean note title, and spend/income type from transcribed text.
  static ParsedVoiceEntry parseEntry(String rawText, double amount) {
    final lower = rawText.toLowerCase();

    // Clean note: strip numbers, currencies and filler prepositions
    String cleanNote = rawText
        .replaceAll(RegExp(r'\b\d+(?:\.\d+)?\b'), ' ')
        .replaceAll(
          RegExp(r'\b\d+(?:st|nd|rd|th)\b', caseSensitive: false),
          ' ',
        )
        .replaceAll(RegExp(r'[₹$€£,.]'), ' ')
        .replaceAll(
          RegExp(
            r'\b(?:rs\.?|rupees|inr|bucks|dollars)\b',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(
          RegExp(
            r'\b(?:for|paid|spent|cost|yesterday|today|was)\b',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleanNote.isNotEmpty) {
      cleanNote = cleanNote[0].toUpperCase() + cleanNote.substring(1);
    }

    String transactionType = 'Spend';
    String category = 'Other';
    String itemName = cleanNote.isNotEmpty ? cleanNote : 'Voice Entry';

    if (lower.contains('salary') || lower.contains('income')) {
      transactionType = 'Income';
      category = 'Income';
      itemName = cleanNote.isNotEmpty ? cleanNote : 'Salary Deposit';
    } else if (lower.contains('uber') ||
        lower.contains('ola') ||
        lower.contains('cab') ||
        lower.contains('auto') ||
        lower.contains('taxi') ||
        lower.contains('metro') ||
        lower.contains('bus') ||
        lower.contains('train') ||
        lower.contains('flight') ||
        lower.contains('fuel') ||
        lower.contains('petrol') ||
        lower.contains('diesel') ||
        lower.contains('travel') ||
        lower.contains('transport')) {
      transactionType = 'Spend';
      category = 'Travel';
      itemName = cleanNote.isNotEmpty ? cleanNote : 'Travel';
    } else if (lower.contains('lunch') ||
        lower.contains('dinner') ||
        lower.contains('breakfast') ||
        lower.contains('food') ||
        lower.contains('coffee') ||
        lower.contains('tea') ||
        lower.contains('cafe') ||
        lower.contains('snack') ||
        lower.contains('pizza') ||
        lower.contains('burger') ||
        lower.contains('restaurant') ||
        lower.contains('grocer')) {
      transactionType = 'Spend';
      category = 'Food';
      itemName = cleanNote.isNotEmpty ? cleanNote : 'Food';
    } else if (lower.contains('shop') ||
        lower.contains('clothes') ||
        lower.contains('amazon') ||
        lower.contains('flipkart') ||
        lower.contains('myntra') ||
        lower.contains('shoes') ||
        lower.contains('dress')) {
      transactionType = 'Spend';
      category = 'Shopping';
      itemName = cleanNote.isNotEmpty ? cleanNote : 'Shopping';
    } else if (lower.contains('bill') ||
        lower.contains('recharge') ||
        lower.contains('electricity') ||
        lower.contains('water') ||
        lower.contains('wifi') ||
        lower.contains('rent') ||
        lower.contains('gas')) {
      transactionType = 'Spend';
      category = 'Bills';
      itemName = cleanNote.isNotEmpty ? cleanNote : 'Bills';
    } else if (lower.contains('doctor') ||
        lower.contains('medicine') ||
        lower.contains('hospital') ||
        lower.contains('pharmacy') ||
        lower.contains('health')) {
      transactionType = 'Spend';
      category = 'Health';
      itemName = cleanNote.isNotEmpty ? cleanNote : 'Health';
    }

    return ParsedVoiceEntry(
      amount: amount,
      note: itemName,
      category: category,
      transactionType: transactionType,
    );
  }
}
