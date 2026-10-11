import 'dart:convert';
import 'package:get/get.dart';
import '../core/db/db_helper.dart';
import '../models/watch_model.dart';
import '../models/search_query_model.dart';
import 'auth_controller.dart';

class BookmarkController extends GetxController {
  final DbHelper _dbHelper = DbHelper();
  final AuthController _auth = Get.find<AuthController>();

  final RxList<WatchModel> bookmarkedWatches = <WatchModel>[].obs;
  final RxList<SearchQueryModel> savedSearches = <SearchQueryModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Fetch bookmarks once user session is ready
    ever(_auth.currentUser, (user) {
      if (user != null) {
        fetchBookmarks();
        fetchSavedSearches();
      } else {
        bookmarkedWatches.clear();
        savedSearches.clear();
      }
    });
    
    // Initial fetch if user already loaded
    if (_auth.currentUser.value != null) {
      fetchBookmarks();
      fetchSavedSearches();
    }
  }

  // 1. Fetch saved listings
  Future<void> fetchBookmarks() async {
    final user = _auth.currentUser.value;
    if (user == null || user.id == null) return;

    isLoading.value = true;
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT l.* FROM listings l
        INNER JOIN bookmarks b ON l.id = b.listing_id
        WHERE b.user_id = ?
      ''', [user.id]);
      
      final list = maps.map((m) => WatchModel.fromMap(m)).toList();
      bookmarkedWatches.assignAll(list);
    } catch (e) {
      print("Error fetching bookmarks: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle Bookmark
  Future<void> toggleBookmark(WatchModel watch) async {
    final user = _auth.currentUser.value;
    if (user == null || user.id == null || watch.id == null) return;

    try {
      final db = await _dbHelper.database;
      final isSaved = isBookmarked(watch.id!);

      if (isSaved) {
        // Delete
        await db.delete(
          'bookmarks',
          where: 'user_id = ? AND listing_id = ?',
          whereArgs: [user.id, watch.id],
        );
        bookmarkedWatches.removeWhere((w) => w.id == watch.id);
        Get.snackbar("Bookmark Removed", "Removed ${watch.title} from bookmarks.");
      } else {
        // Insert
        await db.insert('bookmarks', {
          'user_id': user.id,
          'listing_id': watch.id,
        });
        bookmarkedWatches.add(watch);
        Get.snackbar("Bookmark Saved", "Saved ${watch.title} to bookmarks.");
      }
    } catch (e) {
      print("Error toggling bookmark: $e");
    }
  }

  bool isBookmarked(int listingId) {
    return bookmarkedWatches.any((w) => w.id == listingId);
  }

  // 2. Fetch saved searches
  Future<void> fetchSavedSearches() async {
    final user = _auth.currentUser.value;
    if (user == null || user.id == null) return;

    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'saved_searches',
        where: 'user_id = ?',
        whereArgs: [user.id],
      );
      
      final bool hasMockup = maps.any((m) => m['query_text'].toString().contains("Rolex Submariner 2020"));
      if (!hasMockup) {
        // Seed the 3 mock searches from the screenshot for a premium first-time experience!
        final mockSearches = [
          {
            'user_id': user.id,
            'query_text': 'Rolex Submariner 2020',
            'filters_json': jsonEncode({
              'platforms': ['EBAY', 'CHRONO24', 'GRAILZEE'],
              'chips': ['Year: 2020+', '\$8k - \$14k', 'Excellent', 'EU/US'],
              'alertStatus': 'Price Drop Alerts Enabled',
              'matchesCount': 148,
              'timeAgo': '2 hours ago',
              'alertsEnabled': true,
              'alertType': 'price_drop'
            }),
          },
          {
            'user_id': user.id,
            'query_text': 'Omega Speedmaster Pro',
            'filters_json': jsonEncode({
              'platforms': ['CHRONO24', 'BOB\'S WATCHES'],
              'chips': ['Sapphire', 'Under \$6,500', 'Mint'],
              'alertStatus': 'New Listings Alerts Enabled',
              'matchesCount': 42,
              'timeAgo': '15 mins ago',
              'alertsEnabled': true,
              'alertType': 'new_listings'
            }),
          },
          {
            'user_id': user.id,
            'query_text': 'Patek Philippe Calatrava',
            'filters_json': jsonEncode({
              'platforms': ['SOTHEBY\'S', 'CHRONO24'],
              'chips': ['Yellow Gold', 'Vintage'],
              'alertStatus': 'Push Notifications Off',
              'matchesCount': 12,
              'timeAgo': '1 day ago',
              'alertsEnabled': false,
              'alertType': 'none'
            }),
          }
        ];
        
        for (var s in mockSearches) {
          await db.insert('saved_searches', s);
        }
        
        // Re-query
        final List<Map<String, dynamic>> refMaps = await db.query(
          'saved_searches',
          where: 'user_id = ?',
          whereArgs: [user.id],
        );
        final list = refMaps.map((m) => SearchQueryModel.fromMap(m)).toList();
        savedSearches.assignAll(list);
      } else {
        final list = maps.map((m) => SearchQueryModel.fromMap(m)).toList();
        savedSearches.assignAll(list);
      }
    } catch (e) {
      print("Error fetching saved searches: $e");
    }
  }

  // Save Search Parameters
  Future<void> saveSearch(String query, Map<String, dynamic> filters) async {
    final user = _auth.currentUser.value;
    if (user == null || user.id == null) return;

    try {
      final db = await _dbHelper.database;
      final filtersJsonStr = jsonEncode(filters);

      // Check duplicates
      final List<Map<String, dynamic>> maps = await db.query(
        'saved_searches',
        where: 'user_id = ? AND query_text = ? AND filters_json = ?',
        whereArgs: [user.id, query, filtersJsonStr],
      );

      if (maps.isNotEmpty) {
        Get.snackbar("Search Already Saved", "This search query with filters is already saved.");
        return;
      }

      final id = await db.insert('saved_searches', {
        'user_id': user.id,
        'query_text': query,
        'filters_json': filtersJsonStr,
      });

      savedSearches.add(SearchQueryModel(
        id: id,
        userId: user.id!,
        queryText: query,
        filtersJson: filtersJsonStr,
      ));
      Get.snackbar("Search Saved", "Your search query and filters have been bookmarked.");
    } catch (e) {
      print("Error saving search: $e");
    }
  }

  // Remove Saved Search
  Future<void> removeSavedSearch(int savedSearchId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'saved_searches',
        where: 'id = ?',
        whereArgs: [savedSearchId],
      );
      savedSearches.removeWhere((s) => s.id == savedSearchId);
      Get.snackbar("Search Removed", "Removed saved search.");
    } catch (e) {
      print("Error deleting saved search: $e");
    }
  }
}
