import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/search_controller.dart';
import '../../../controllers/bookmark_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/watch_model.dart';
import '../watch_detail_screen.dart';
import '../../widgets/watch_background.dart';
import '../../../core/db/db_helper.dart';
import '../../search/image_search_screen.dart';

class SearchTab extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const SearchTab({super.key, this.onBackToHome});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final WatchSearchController _search = Get.find<WatchSearchController>();
  final BookmarkController _bookmark = Get.find<BookmarkController>();
  final AuthController _auth = Get.find<AuthController>();
  
  final TextEditingController _queryController = TextEditingController();
  bool _isGridView = false; // Toggles between Screenshot 2 full-width list and 2-column grid

  @override
  void initState() {
    super.initState();
    _queryController.text = _search.queryText.value;
    // Auto execute search on start if query exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _search.executeSearch(_queryController.text);
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _onSearchSubmit(String val) {
    _search.executeSearch(val);
  }

  void _showFilterBottomSheet() {
    Get.bottomSheet(
      _FilterBottomSheetContent(
        search: _search,
        auth: _auth,
        query: _queryController,
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }

  void _showImageSearchMockDialog() {
    Get.to(() => const ImageSearchScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WatchBackground(
        showGears: true,
        showDialTicks: true,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. Custom AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.textPrimaryColor, size: 22),
                      onPressed: widget.onBackToHome,
                    ),
                    Text(
                      "Timepieces",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: context.textPrimaryColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.shopping_bag_outlined, color: context.textPrimaryColor, size: 24),
                      onPressed: () {
                        Get.snackbar(
                          "Shopping Cart",
                          "Cart features coming soon!",
                          backgroundColor: context.cardBg.withValues(alpha: 0.9),
                          colorText: context.textPrimaryColor,
                          boxShadows: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              // 2. Premium Search Bar Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.03),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: TextField(
                    controller: _queryController,
                    onSubmitted: _onSearchSubmit,
                    style: TextStyle(color: context.textPrimaryColor),
                    decoration: InputDecoration(
                      hintText: "Search Rolex, Omega, Patek Philippe...",
                      hintStyle: TextStyle(color: context.textSecondaryColor, fontSize: 15),
                      prefixIcon: Icon(Icons.search_rounded, color: context.textSecondaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.camera_alt_outlined, color: context.primaryNav),
                        onPressed: _showImageSearchMockDialog,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: context.borderColor, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: context.borderColor, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: context.primaryNav, width: 1.5),
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Scrollable Horizontal Filter Chips
              const SizedBox(height: 8),
              _buildHorizontalFilterChips(context),
              const SizedBox(height: 12),

              // 4. Results header (Count, filter, grid/list toggle)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() {
                      final count = _search.searchResults.length;
                      return Text(
                        "$count TIMEPIECES",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: context.textSecondaryColor,
                          letterSpacing: 0.8,
                        ),
                      );
                    }),
                    Row(
                      children: [
                        // Filters Tuner Box
                        GestureDetector(
                          onTap: _showFilterBottomSheet,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: context.chipBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.tune_rounded,
                              size: 18,
                              color: context.textPrimaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Segmented Layout Grid/List Switcher
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: context.chipBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => _isGridView = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: !_isGridView ? context.cardBg : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: !_isGridView
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.05),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: Icon(
                                    Icons.view_list_rounded,
                                    size: 16,
                                    color: !_isGridView ? context.primaryNav : context.textSecondaryColor,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => _isGridView = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _isGridView ? context.cardBg : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: _isGridView
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.05),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: Icon(
                                    Icons.grid_view_rounded,
                                    size: 16,
                                    color: _isGridView ? context.primaryNav : context.textSecondaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),

              // 5. Results Grid or List
              Expanded(
                child: Obx(() {
                  if (_search.isLoading.value) {
                    return Center(child: CircularProgressIndicator(color: context.primaryNav));
                  }

                  if (_search.searchResults.isEmpty) {
                    return _buildEmptySuggestionsView(context);
                  }

                  return _isGridView ? _buildResultsGridView() : _buildResultsListView();
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Horizontal chips row with active highlight
  Widget _buildHorizontalFilterChips(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Obx(() {
        final hasPriceFilter = _search.filterPriceMin.value != null || _search.filterPriceMax.value != null;
        final hasYearFilter = _search.filterYearMin.value != null || _search.filterYearMax.value != null;
        final hasConditionFilter = _search.filterCondition.value.isNotEmpty;
        final hasMarketplaceFilter = !_search.searchChrono24.value || !_search.searchEbay.value || !_search.searchGrailzee.value;

        return ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            _buildFilterChip(context, "Price", hasPriceFilter),
            _buildFilterChip(context, "Year", hasYearFilter),
            _buildFilterChip(context, "Condition", hasConditionFilter),
            _buildFilterChip(context, "Marketplace", hasMarketplaceFilter),
          ],
        );
      }),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        onPressed: _showFilterBottomSheet,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : context.textSecondaryColor,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 14,
              color: isActive ? Colors.white : context.textSecondaryColor,
            ),
          ],
        ),
        backgroundColor: isActive ? context.primaryNav : context.chipBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isActive ? context.primaryNav : Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySuggestionsView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Center(
            child: Icon(Icons.explore_outlined, size: 64, color: context.textSecondaryColor),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              "Start your Horology search",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              "Type a model name above to aggregate multi-platform items.",
              style: TextStyle(fontSize: 13, color: context.textSecondaryColor),
            ),
          ),
          const SizedBox(height: 36),
          
          Text(
            "Popular Watches:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.textPrimaryColor),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ["Rolex", "Submariner", "Omega", "Speedmaster", "Nautilus", "Royal Oak"]
                .map((kw) => ActionChip(
                      label: Text(kw, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.textPrimaryColor)),
                      onPressed: () {
                        _queryController.text = kw;
                        _search.executeSearch(kw);
                      },
                      backgroundColor: context.chipBg,
                      side: BorderSide(color: context.borderColor),
                    ))
                .toList(),
          ),
          const SizedBox(height: 32),
          
          if (_search.searchHistory.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Recent Searches", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.textPrimaryColor)),
                TextButton(
                  onPressed: _search.clearHistory,
                  child: const Text("Clear All", style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 4),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _search.searchHistory.length,
              itemBuilder: (context, idx) {
                final hist = _search.searchHistory[idx];
                final kw = hist['query_text'] as String;
                return ListTile(
                  leading: Icon(Icons.history_rounded, size: 20, color: context.textSecondaryColor),
                  title: Text(kw, style: TextStyle(fontSize: 14, color: context.textPrimaryColor, fontWeight: FontWeight.w500)),
                  contentPadding: EdgeInsets.zero,
                  trailing: Icon(Icons.arrow_outward_rounded, size: 16, color: context.textSecondaryColor),
                  onTap: () {
                    _queryController.text = kw;
                    _search.executeSearch(kw);
                  },
                );
              },
            ),
          ]
        ],
      ),
    );
  }

  // 1-column Vertical ListView matching Screenshot 2
  Widget _buildResultsListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      itemCount: _search.searchResults.length,
      itemBuilder: (context, index) {
        final watch = _search.searchResults[index];
        return _buildWatchListCard(watch);
      },
    );
  }

  // Custom Full-Width List Card layout from Screenshot 2
  Widget _buildWatchListCard(WatchModel watch) {
    final priceStr = watch.price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    return InkWell(
      onTap: () => Get.to(() => WatchDetailScreen(watch: watch)),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: _buildWatchImage(context, watch, 220),
                ),
                // Premium Badge "TOP VERIFIED" on the bottom left of the image
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: context.primaryNav,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "TOP VERIFIED",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                // Heart Bookmark icon top right
                Positioned(
                  top: 12,
                  right: 12,
                  child: Obx(() {
                    final isSaved = _bookmark.isBookmarked(watch.id!);
                    return GestureDetector(
                      onTap: () => _bookmark.toggleBookmark(watch),
                      child: Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          color: context.chipBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isSaved ? Colors.red : context.textSecondaryColor,
                          size: 20,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),

            // Card Text Details
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    watch.brand.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: context.textSecondaryColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          watch.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimaryColor,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "\$$priceStr",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: context.primaryNav,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Specs tag pills row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildSpecPill(context, "${watch.year}"),
                        const SizedBox(width: 6),
                        _buildSpecPill(context, "41mm"),
                        const SizedBox(width: 6),
                        _buildSpecPill(context, watch.condition),
                        const SizedBox(width: 6),
                        _buildSpecPill(
                          context,
                          watch.location,
                          leading: Icon(Icons.public_rounded, size: 10, color: context.textSecondaryColor),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSpecPill(BuildContext context, String text, {Widget? leading}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.chipBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading,
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // 2-column GridView fallback
  Widget _buildResultsGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: _search.searchResults.length,
      itemBuilder: (context, index) {
        final watch = _search.searchResults[index];
        return _buildWatchGridCard(watch);
      },
    );
  }

  Widget _buildWatchGridCard(WatchModel watch) {
    final priceStr = watch.price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    return InkWell(
      onTap: () => Get.to(() => WatchDetailScreen(watch: watch)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: _buildWatchImage(context, watch, double.infinity),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Obx(() {
                      final isSaved = _bookmark.isBookmarked(watch.id!);
                      return GestureDetector(
                        onTap: () => _bookmark.toggleBookmark(watch),
                        child: Container(
                          height: 28,
                          width: 28,
                          decoration: BoxDecoration(
                            color: context.chipBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isSaved ? Colors.red : context.textSecondaryColor,
                            size: 14,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    watch.brand.toUpperCase(),
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: context.textSecondaryColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    watch.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "\$$priceStr",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: context.primaryNav),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Generates high-fidelity center-aligned watch photo on premium dark gradient
  Widget _buildWatchImage(BuildContext context, WatchModel watch, double height) {
    final String imageUrl = watch.imageUrl;

    return Container(
      height: height,
      color: context.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Sub-guilloche rings in card backdrop
          Opacity(
            opacity: 0.08,
            child: CustomPaint(
              painter: _MiniDialPainter(
                lineColor: context.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          Image.asset(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

// Mini Dial Painter for Watch Cards Backdrop
class _MiniDialPainter extends CustomPainter {
  final Color lineColor;
  _MiniDialPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 1; i <= 6; i++) {
      canvas.drawCircle(center, i * 22.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniDialPainter oldDelegate) => oldDelegate.lineColor != lineColor;
}

// ----------------------------------------------------
// DEDICATED STATEFUL SHEET FOR SCREENSHOT 3 DESIGN
// ----------------------------------------------------
class _FilterBottomSheetContent extends StatefulWidget {
  final WatchSearchController search;
  final AuthController auth;
  final TextEditingController query;

  const _FilterBottomSheetContent({
    required this.search,
    required this.auth,
    required this.query,
  });

  @override
  State<_FilterBottomSheetContent> createState() => _FilterBottomSheetContentState();
}

class _FilterBottomSheetContentState extends State<_FilterBottomSheetContent> {
  late TextEditingController _localQueryController;
  
  // Local Filter settings
  late double _priceMin;
  late double _priceMax;
  late int _yearMin;
  late int _yearMax;
  late String _location;
  late String _condition;
  late bool _showSold;
  
  // Marketplace platform selections
  late bool _chrono24Selected;
  late bool _bobsSelected;
  late bool _sothebysSelected;
  late bool _watchBoxSelected;

  int _matchCount = 0;
  bool _counting = false;

  @override
  void initState() {
    super.initState();
    _localQueryController = TextEditingController(text: widget.query.text);
    
    _priceMin = widget.search.filterPriceMin.value ?? 5000.0;
    _priceMax = widget.search.filterPriceMax.value ?? 150000.0;
    
    _yearMin = widget.search.filterYearMin.value ?? 1950;
    _yearMax = widget.search.filterYearMax.value ?? 2024;
    
    _location = widget.search.filterLocation.value;
    _condition = widget.search.filterCondition.value;
    _showSold = widget.search.filterShowSold.value;
    
    _chrono24Selected = widget.search.searchChrono24.value;
    _bobsSelected = widget.search.searchEbay.value;
    _sothebysSelected = widget.search.searchGrailzee.value;
    _watchBoxSelected = true; // Simulated

    _updateMatchCount();
  }

  @override
  void dispose() {
    _localQueryController.dispose();
    super.dispose();
  }

  // Dynamically counts search matches based on active parameters
  Future<void> _updateMatchCount() async {
    if (!mounted) return;
    setState(() {
      _counting = true;
    });

    try {
      final dbHelper = DbHelper();
      final db = await dbHelper.database;
      
      String query = "SELECT COUNT(*) as count FROM listings WHERE 1=1";
      List<dynamic> arguments = [];

      if (_localQueryController.text.isNotEmpty) {
        query += " AND (title LIKE ? OR brand LIKE ? OR model LIKE ?)";
        arguments.add('%${_localQueryController.text}%');
        arguments.add('%${_localQueryController.text}%');
        arguments.add('%${_localQueryController.text}%');
      }

      List<String> activePlatforms = [];
      if (_chrono24Selected) activePlatforms.add('Chrono24');
      if (_bobsSelected) activePlatforms.add('eBay');
      if (_sothebysSelected) activePlatforms.add('Grailzee');

      if (activePlatforms.isEmpty) {
        if (mounted) {
          setState(() {
            _matchCount = 0;
            _counting = false;
          });
        }
        return;
      }
      query += " AND platform IN (${activePlatforms.map((p) => '?').join(', ')})";
      arguments.addAll(activePlatforms);

      // Price Filter
      query += " AND price >= ? AND price <= ?";
      arguments.add(_priceMin);
      arguments.add(_priceMax);

      // Year Filter
      query += " AND year >= ? AND year <= ?";
      arguments.add(_yearMin);
      arguments.add(_yearMax);

      if (_location.isNotEmpty && _location != "Global") {
        query += " AND location = ?";
        arguments.add(_location);
      }

      if (_condition.isNotEmpty) {
        query += " AND condition = ?";
        arguments.add(_condition);
      }

      query += " AND is_sold = ?";
      arguments.add(_showSold ? 1 : 0);

      final result = await db.rawQuery(query, arguments);
      if (result.isNotEmpty && mounted) {
        setState(() {
          _matchCount = result.first['count'] as int;
        });
      }
    } catch (e) {
      print("Error updates count: $e");
    } finally {
      if (mounted) {
        setState(() {
          _counting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.auth.currentUser.value;
    final isPremium = user != null && (user.plan == 'paid' || user.role == 'admin');

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle indicator
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Advanced Refinement",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.primaryNav,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Configure multi-market parameters for horological sourcing.",
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondaryColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.close_rounded, color: context.textSecondaryColor, size: 24),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Main Form Fields (Scrollable)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Keyword Refinement
                  _buildSectionLabel("KEYWORD REFINEMENT"),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: context.chipBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _localQueryController,
                      onChanged: (_) => _updateMatchCount(),
                      style: TextStyle(color: context.textPrimaryColor),
                      decoration: InputDecoration(
                        hintText: "Reference, Brand, or Model...",
                        hintStyle: TextStyle(color: context.textSecondaryColor, fontSize: 14),
                        prefixIcon: Icon(Icons.search_rounded, color: context.textSecondaryColor, size: 20),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: context.borderColor, width: 1.2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: context.borderColor, width: 1.2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: context.primaryNav, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Marketplace 2x2 Grid
                  _buildSectionLabel("MARKETPLACE"),
                  const SizedBox(height: 10),
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.2,
                    ),
                    children: [
                      _buildMarketCard("CHRONO24", Icons.storefront_rounded, _chrono24Selected, () {
                        setState(() => _chrono24Selected = !_chrono24Selected);
                        _updateMatchCount();
                      }),
                      _buildMarketCard("BOB'S", Icons.diamond_outlined, _bobsSelected, () {
                        setState(() => _bobsSelected = !_bobsSelected);
                        _updateMatchCount();
                      }),
                      _buildMarketCard("SOTHEBY'S", Icons.gavel_rounded, _sothebysSelected, () {
                        setState(() => _sothebysSelected = !_sothebysSelected);
                        _updateMatchCount();
                      }),
                      _buildMarketCard("WATCHBOX", Icons.photo_library_outlined, _watchBoxSelected, () {
                        setState(() => _watchBoxSelected = !_watchBoxSelected);
                        _updateMatchCount();
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 3. Price Range (USD)
                  _buildSectionLabel("PRICE RANGE (USD)"),
                  const SizedBox(height: 6),
                  RangeSlider(
                    values: RangeValues(_priceMin, _priceMax),
                    min: 0,
                    max: 200000,
                    divisions: 40,
                    activeColor: context.primaryNav,
                    inactiveColor: context.chipBg,
                    labels: RangeLabels('\$${_priceMin.round()}', '\$${_priceMax.round()}'),
                    onChanged: (values) {
                      setState(() {
                        _priceMin = values.start;
                        _priceMax = values.end;
                      });
                      _updateMatchCount();
                    },
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: context.chipBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: context.borderColor, width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("MIN", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: context.textSecondaryColor)),
                              const SizedBox(height: 2),
                              Text("\$ ${_priceMin.round()}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.textPrimaryColor)),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Container(width: 12, height: 2, color: context.borderColor),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: context.chipBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: context.borderColor, width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("MAX", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: context.textSecondaryColor)),
                              const SizedBox(height: 2),
                              Text("\$ ${_priceMax.round()}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.textPrimaryColor)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 4. Production Year Slider (Premium Locked warning overlay if free tier)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionLabel("PRODUCTION YEAR"),
                      Text(
                        "$_yearMin — $_yearMax",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.primaryNav),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Stack(
                    children: [
                      Column(
                        children: [
                          RangeSlider(
                            values: RangeValues(_yearMin.toDouble(), _yearMax.toDouble()),
                            min: 1950,
                            max: 2024,
                            divisions: 74,
                            activeColor: context.primaryNav,
                            inactiveColor: context.chipBg,
                            onChanged: isPremium ? (values) {
                              setState(() {
                                _yearMin = values.start.round();
                                _yearMax = values.end.round();
                              });
                              _updateMatchCount();
                            } : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("1950", style: TextStyle(fontSize: 10, color: context.textSecondaryColor)),
                                Text("2024", style: TextStyle(fontSize: 10, color: context.textSecondaryColor)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (!isPremium) _buildLockOverlay(),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 5. Listing Status Custom Segmented Control
                  _buildSectionLabel("LISTING STATUS"),
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      Container(
                        height: 46,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: context.chipBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: isPremium ? () {
                                  setState(() => _showSold = false);
                                  _updateMatchCount();
                                } : null,
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: !_showSold ? context.cardBg : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: !_showSold
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.04),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    "Active Listings",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: !_showSold ? context.primaryNav : context.textSecondaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: isPremium ? () {
                                  setState(() => _showSold = true);
                                  _updateMatchCount();
                                } : null,
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: _showSold ? context.cardBg : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: _showSold
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.04),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    "Historical Sold",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: _showSold ? context.primaryNav : context.textSecondaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isPremium) _buildLockOverlay(),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 6. Condition Detail Tags
                  _buildSectionLabel("CONDITION DETAIL"),
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildConditionChip("New", "243"),
                          _buildConditionChip("Unworn", "1,052"),
                          _buildConditionChip("Very Good", "4,821"),
                          _buildConditionChip("Vintage", "892"),
                        ],
                      ),
                      if (!isPremium) _buildLockOverlay(),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 7. Sourcing Region Dropdown
                  _buildSectionLabel("SOURCING REGION"),
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: isPremium ? _showRegionSelector : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: context.cardBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: context.borderColor, width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.public_rounded, size: 20, color: context.textSecondaryColor),
                                  const SizedBox(width: 12),
                                  Text(
                                    _location.isEmpty ? "Global (All Locations)" : _location,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: context.primaryNav,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(Icons.keyboard_arrow_down_rounded, color: context.textSecondaryColor),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Includes EU, USA, Japan, and UAE markets",
                            style: TextStyle(fontSize: 11, color: context.textSecondaryColor),
                          ),
                        ],
                      ),
                      if (!isPremium) _buildLockOverlay(),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // 8. Footer Action buttons
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _counting ? null : () {
                    // Update filters to search controller
                    widget.search.filterPriceMin.value = _priceMin;
                    widget.search.filterPriceMax.value = _priceMax;
                    widget.search.filterYearMin.value = _yearMin;
                    widget.search.filterYearMax.value = _yearMax;
                    widget.search.filterLocation.value = _location;
                    widget.search.filterCondition.value = _condition;
                    widget.search.filterShowSold.value = _showSold;
                    
                    widget.search.searchChrono24.value = _chrono24Selected;
                    widget.search.searchEbay.value = _bobsSelected;
                    widget.search.searchGrailzee.value = _sothebysSelected;

                    widget.query.text = _localQueryController.text;
                    widget.search.executeSearch(_localQueryController.text);

                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryNav,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _counting ? "Calculating..." : "Show $_matchCount Results",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _priceMin = 5000.0;
                  _priceMax = 150000.0;
                  _yearMin = 1950;
                  _yearMax = 2024;
                  _location = '';
                  _condition = '';
                  _showSold = false;
                  _chrono24Selected = true;
                  _bobsSelected = true;
                  _sothebysSelected = true;
                });
                _updateMatchCount();
              },
              child: Text(
                "Reset Filters",
                style: TextStyle(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (!isPremium) ...[
            const SizedBox(height: 4),
            Center(
              child: GestureDetector(
                onTap: () {
                  Get.back();
                  widget.auth.upgradePlan();
                },
                child: Text(
                  "Unlock Advanced Filters for \$29/mo",
                  style: TextStyle(
                    color: context.primaryNav,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: context.textSecondaryColor,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildMarketCard(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? context.chipBg : context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? context.primaryNav : context.borderColor,
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.primaryNav.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? context.primaryNav : context.textSecondaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isSelected ? context.primaryNav : context.textSecondaryColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionChip(String label, String count) {
    final bool isSelected = _condition == label;

    return ChoiceChip(
      label: Text(
        "$label ($count)",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : context.textSecondaryColor,
        ),
      ),
      selected: isSelected,
      onSelected: (val) {
        setState(() {
          _condition = val ? label : '';
        });
        _updateMatchCount();
      },
      selectedColor: context.primaryNav,
      backgroundColor: context.chipBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide(color: isSelected ? context.primaryNav : Colors.transparent),
      showCheckmark: false,
    );
  }

  void _showRegionSelector() {
    Get.dialog(
      SimpleDialog(
        title: Text("Select Sourcing Region", style: TextStyle(fontWeight: FontWeight.bold, color: context.primaryNav)),
        backgroundColor: context.surfaceBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        children: ["Global", "USA", "Germany", "Japan", "Switzerland", "UK"]
            .map((loc) => SimpleDialogOption(
                  onPressed: () {
                    setState(() {
                      _location = loc == "Global" ? "" : loc;
                    });
                    _updateMatchCount();
                    Get.back();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      children: [
                        Icon(
                          loc == "Global" ? Icons.public_rounded : Icons.location_on_rounded,
                          size: 18,
                          color: context.textSecondaryColor,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          loc == "Global" ? "Global (All Locations)" : loc,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.textPrimaryColor),
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  // Visual Lock overlay screen for premium tier filters
  Widget _buildLockOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          Get.snackbar(
            "Premium Feature",
            "Upgrade to Premium to unlock advanced watch refinement filters.",
            backgroundColor: context.surfaceBg,
            colorText: context.textPrimaryColor,
            icon: Icon(Icons.lock_rounded, color: context.primaryNav),
            boxShadows: [
              BoxShadow(
                color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: context.surfaceBg.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.lock_rounded,
                color: context.primaryNav,
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
