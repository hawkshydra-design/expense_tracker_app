import '../models/category.dart';

/// Keyword-based auto-categorizer for detected UPI transactions.
///
/// Scans merchant name and raw notification text for known keywords
/// and maps them to [ExpenseCategory] values.
class AutoCategorizer {
  AutoCategorizer._();

  /// Keyword → category mapping table.
  /// Order matters: first match wins.
  static const _keywordMap = <ExpenseCategory, List<String>>{
    ExpenseCategory.food: [
      'swiggy',
      'zomato',
      'restaurant',
      'food',
      'cafe',
      'coffee',
      'pizza',
      'burger',
      'dominos',
      'mcdonalds',
      'kfc',
      'subway',
      'starbucks',
      'dunkin',
      'biryani',
      'kitchen',
      'dhaba',
      'bakery',
      'ice cream',
      'eat',
      'dine',
      'meal',
      'lunch',
      'dinner',
      'breakfast',
      'snack',
      'chai',
      'tea',
      'blinkit',
      'zepto',
      'instamart',
      'bigbasket',
      'grofers',
      'grocery',
    ],
    ExpenseCategory.transport: [
      'uber',
      'ola',
      'rapido',
      'metro',
      'fuel',
      'petrol',
      'diesel',
      'parking',
      'irctc',
      'railway',
      'train',
      'flight',
      'bus',
      'cab',
      'taxi',
      'auto',
      'rickshaw',
      'toll',
      'makemytrip',
      'goibibo',
      'cleartrip',
      'redbus',
      'yatra',
      'indigo',
      'spicejet',
      'vistara',
      'air india',
      'bike',
      'ride',
      'travel',
    ],
    ExpenseCategory.shopping: [
      'amazon',
      'flipkart',
      'myntra',
      'ajio',
      'meesho',
      'mall',
      'shop',
      'store',
      'mart',
      'tata cliq',
      'nykaa',
      'snapdeal',
      'jiomart',
      'croma',
      'reliance',
      'dmart',
      'decathlon',
      'ikea',
      'h&m',
      'zara',
      'fashion',
      'clothing',
      'electronics',
      'gadget',
      'mobile',
      'phone',
      'laptop',
    ],
    ExpenseCategory.bills: [
      'electricity',
      'broadband',
      'jio',
      'airtel',
      'vi ',
      'vodafone',
      'bsnl',
      'gas',
      'water',
      'rent',
      'recharge',
      'bill',
      'dth',
      'tata sky',
      'dish tv',
      'insurance',
      'lic',
      'premium',
      'emi',
      'loan',
      'credit card',
      'postpaid',
      'prepaid',
      'wifi',
      'internet',
      'municipal',
      'tax',
      'society',
      'maintenance',
    ],
    ExpenseCategory.entertainment: [
      'netflix',
      'spotify',
      'hotstar',
      'pvr',
      'inox',
      'gaming',
      'youtube',
      'prime video',
      'disney',
      'zee5',
      'sonyliv',
      'jiocinema',
      'bookmyshow',
      'movie',
      'cinema',
      'concert',
      'event',
      'ticket',
      'game',
      'play',
      'steam',
      'playstation',
      'xbox',
      'subscription',
      'music',
      'apple music',
    ],
    ExpenseCategory.health: [
      'apollo',
      'pharmacy',
      'hospital',
      'medplus',
      '1mg',
      'doctor',
      'clinic',
      'medical',
      'medicine',
      'health',
      'diagnostic',
      'lab',
      'test',
      'pathology',
      'dentist',
      'eye',
      'optical',
      'gym',
      'fitness',
      'yoga',
      'pharmeasy',
      'netmeds',
      'practo',
      'wellness',
      'physiotherapy',
    ],
    ExpenseCategory.education: [
      'udemy',
      'coursera',
      'books',
      'school',
      'college',
      'tuition',
      'education',
      'university',
      'academy',
      'coaching',
      'class',
      'exam',
      'study',
      'library',
      'stationery',
      'skillshare',
      'unacademy',
      'byju',
      'vedantu',
      'khan academy',
      'linkedin learning',
    ],
  };

  /// Categorize a transaction based on merchant name and raw text.
  ///
  /// Checks merchant name first (higher priority), then falls back
  /// to scanning the full notification text. Returns [ExpenseCategory.other]
  /// if no keyword matches.
  static ExpenseCategory categorize({
    String? merchant,
    required String rawText,
  }) {
    // Normalize inputs to lowercase for matching
    final merchantLower = merchant?.toLowerCase() ?? '';
    final textLower = rawText.toLowerCase();

    // First pass: check merchant name (most reliable)
    if (merchantLower.isNotEmpty) {
      for (final entry in _keywordMap.entries) {
        for (final keyword in entry.value) {
          if (merchantLower.contains(keyword)) {
            return entry.key;
          }
        }
      }
    }

    // Second pass: check full notification text
    for (final entry in _keywordMap.entries) {
      for (final keyword in entry.value) {
        if (textLower.contains(keyword)) {
          return entry.key;
        }
      }
    }

    return ExpenseCategory.other;
  }
}
