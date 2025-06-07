// test_search.dart
import 'lib/screens/search_screen.dart';
import 'lib/models/store.dart';

void main() {
  // Test if SearchScreen is accessible
  final testScreen = SearchScreen(
    stores: <Store>[],
    favoriteStoreIds: <String>{},
    onToggleStoreFavorite: (id) {},
  );
  print('SearchScreen created successfully');
}
