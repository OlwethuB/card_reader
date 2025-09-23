class OcrUtils {
  static String extractCardNumber(String text) {
    print("Original OCR text: $text");
    
    // Method 1: Remove spaces and look for 13-19 consecutive digits
    String withoutSpaces = text.replaceAll(RegExp(r'\s+'), '');
    print("Without spaces: $withoutSpaces");
    
    RegExp cardPattern1 = RegExp(r'\d{13,19}');
    Match? match1 = cardPattern1.firstMatch(withoutSpaces);
    
    if (match1 != null) {
      String potentialNumber = match1.group(0)!;
      print("Found via method 1: $potentialNumber");
      
      if (_isValidCardFormat(potentialNumber)) {
        return potentialNumber;
      }
    }
    
    // Method 2: Look for groups of 4 digits separated by spaces
    RegExp cardPattern2 = RegExp(r'(\d{4}\s?){3,5}');
    Iterable<Match> matches2 = cardPattern2.allMatches(text);
    
    for (Match match in matches2) {
      String potentialNumber = match.group(0)!.replaceAll(RegExp(r'\s+'), '');
      print("Found via method 2: $potentialNumber");
      
      if (potentialNumber.length >= 13 && potentialNumber.length <= 19 && 
          _isValidCardFormat(potentialNumber)) {
        return potentialNumber;
      }
    }
    
    // Method 3: Extract all digits and look for valid sequences
    String allDigits = text.replaceAll(RegExp(r'\D'), '');
    print("All digits: $allDigits");
    
    if (allDigits.length >= 13 && allDigits.length <= 19) {
      if (_isValidCardFormat(allDigits)) {
        return allDigits;
      }
    } else if (allDigits.length > 19) {
      for (int i = 0; i <= allDigits.length - 13; i++) {
        for (int length = 16; length <= 19; length++) {
          if (i + length <= allDigits.length) {
            String substring = allDigits.substring(i, i + length);
            if (_isValidCardFormat(substring)) {
              return substring;
            }
          }
        }
      }
    }
    
    return '';
  }

  static String extractCVV(String text) {
    // Look for 3-4 digit sequences that are not part of card numbers or dates
    String cleaned = text.replaceAll(RegExp(r'\s+'), ' ');
    
    // Common CVV patterns: "CVV: 123", "CVC: 123", "Security Code: 123", or standalone 3-4 digits
    RegExp cvvPattern1 = RegExp(r'(CVV|CVC|Security Code)[:\s]*(\d{3,4})', caseSensitive: false);
    Match? match1 = cvvPattern1.firstMatch(cleaned);
    if (match1 != null) {
      return match1.group(2)!;
    }
    
    // Look for standalone 3-4 digit sequences
    RegExp cvvPattern2 = RegExp(r'\b(\d{3,4})\b');
    Iterable<Match> matches = cvvPattern2.allMatches(cleaned);
    
    for (Match match in matches) {
      String potentialCVV = match.group(1)!;
      // Exclude numbers that are part of dates or card numbers
      if (!_isPartOfDate(potentialCVV, cleaned) && 
          !_isPartOfCardNumber(potentialCVV, cleaned)) {
        return potentialCVV;
      }
    }
    
    return '';
  }

  static Map<String, String> extractExpiryDate(String text) {
    // Common patterns: MM/YY, MM/YYYY, MM-YY, MM-YYYY
    RegExp expiryPattern = RegExp(r'(\d{1,2})[/-](\d{2,4})');
    Iterable<Match> matches = expiryPattern.allMatches(text);
    
    for (Match match in matches) {
      String month = match.group(1)!.padLeft(2, '0');
      String year = match.group(2)!;
      
      // Validate month
      int monthInt = int.tryParse(month) ?? 0;
      if (monthInt >= 1 && monthInt <= 12) {
        // Convert 2-digit year to 4-digit
        if (year.length == 2) {
          int currentYear = DateTime.now().year % 100;
          int yearInt = int.parse(year);
          year = (yearInt >= currentYear ? '20' : '19') + year;
        }
        
        return {'month': month, 'year': year};
      }
    }
    
    return {};
  }

  static String extractCardHolder(String text) {
    // Look for name patterns (2-3 words, title case, not containing numbers)
    List<String> lines = text.split('\n');
    
    for (String line in lines) {
      line = line.trim();
      // Skip lines with numbers, dates, or common card-related terms
      if (line.contains(RegExp(r'\d')) || 
          line.length < 2 ||
          line.toLowerCase().contains(RegExp(r'(card|number|expir|valid|thru|cvv|cvc)'))) {
        continue;
      }
      
      // Check if it looks like a name (2-3 words, proper capitalization)
      List<String> words = line.split(RegExp(r'\s+'));
      if (words.length >= 2 && words.length <= 3) {
        bool looksLikeName = words.every((word) => 
            word.length >= 2 && 
            word[0].toUpperCase() == word[0] &&
            RegExp(r'^[A-Za-z\s.-]+$').hasMatch(word));
        
        if (looksLikeName) {
          return line;
        }
      }
    }
    
    return '';
  }

  static bool _isValidCardFormat(String number) {
    if (!RegExp(r'^\d+$').hasMatch(number)) return false;
    if (number.length < 13 || number.length > 19) return false;
    
    List<RegExp> validPrefixes = [
      RegExp(r'^4'), // Visa
      RegExp(r'^(5[1-5]|2[2-7])'), // MasterCard
      RegExp(r'^3[47]'), // American Express
      RegExp(r'^(6011|65|64[4-9])'), // Discover
      RegExp(r'^(30[0-5]|36|38)'), // Diners Club
      RegExp(r'^(2131|1800|35)'), // JCB
    ];
    
    return validPrefixes.any((pattern) => pattern.hasMatch(number));
  }

  static bool _isPartOfDate(String number, String text) {
    // Check if the number appears near date-related terms
    return text.toLowerCase().contains(RegExp(r'(expir|valid|thru|date|month|year)'));
  }

  static bool _isPartOfCardNumber(String number, String text) {
    // Check if the number is near card number patterns
    int index = text.indexOf(number);
    if (index == -1) return false;
    
    // Check surrounding context
    String context = text.substring(
      index - 10 >= 0 ? index - 10 : 0,
      index + number.length + 10 <= text.length ? index + number.length + 10 : text.length
    ).toLowerCase();
    
    return context.contains(RegExp(r'(card|number|account|#)'));
  }
}