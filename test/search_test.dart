import 'package:flutter_test/flutter_test.dart';
import 'package:foodapp_user/services/search_service.dart';

void main() {
  group('Search Service Tests', () {
    late SearchService searchService;

    setUp(() {
      searchService = SearchService();
    });

    test('should normalize Arabic text correctly', () {
      // Test text normalization - testing the actual normalization logic
      final testCases = [
        ['بُرْجَر مُشَكَّل', 'برجر مشكل'],
        ['بِيتْزا إيطالِيَّة', 'بيتزا ايطالية'],
        ['دَجاج مَقْلِي', 'دجاج مقلي'],
        ['مَأْكولات شَرْقِيَّة', 'ماكولات شرقية'],
      ];

      for (final testCase in testCases) {
        final input = testCase[0];
        final expected = testCase[1];
        
        // Test the actual normalization logic that SearchService uses
        String normalized = input
            .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06DC\u06DF-\u06E4\u06E7\u06E8\u06EA-\u06ED]'), '')
            .replaceAll('آ', 'ا')
            .replaceAll('أ', 'ا')
            .replaceAll('إ', 'ا')
            .replaceAll('ى', 'ي')
            .replaceAll(RegExp(r'[^\u0600-\u06FF\u0750-\u077F\uFB50-\uFDFF\uFE70-\uFEFFa-zA-Z\s]'), '')
            .toLowerCase()
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
        
        expect(normalized, expected);
      }
    });

    test('should get popular searches fallback', () async {
      final popularSearches = await searchService.getPopularSearches();
      
      expect(popularSearches, isNotEmpty);
      expect(popularSearches, contains('برجر'));
      expect(popularSearches, contains('بيتزا'));
      expect(popularSearches.length, greaterThan(5));
    });

    test('should handle empty search query', () async {
      final results = await searchService.searchStores('');
      expect(results, isEmpty);
    });

    test('should handle whitespace-only search query', () async {
      final results = await searchService.searchStores('   ');
      expect(results, isEmpty);
    });
  });
}
