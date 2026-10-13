/// Endpoint paths mirrored from the project's Postman collection
/// (collection.json, baseUrl = AppConstants.baseUrl). Grouped by the same
/// folders as the collection so new endpoints are easy to locate and add.
/// Paths only — ApiClient prefixes them with AppConstants.baseUrl.
class ApiUrl {
  ApiUrl._();

  // 01. Authentication & Sessions
  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/register';
  static const String refresh = '/api/v1/auth/refresh';
  static const String logout = '/api/v1/auth/logout';
  static const String logoutAll = '/api/v1/auth/logout-all';
  static const String verifyEmailRequest = '/api/v1/auth/verify-email/request';
  static const String verifyEmailConfirm = '/api/v1/auth/verify-email/confirm';
  static const String forgotPassword = '/api/v1/auth/forgot-password';
  static const String resetPassword = '/api/v1/auth/reset-password';
  static const String changePassword = '/api/v1/auth/change-password';
  static const String sessions = '/api/v1/auth/sessions';
  static String session(String sessionId) => '/api/v1/auth/sessions/$sessionId';

  // 02. User Profile & Preferences
  static const String me = '/api/v1/users/me';
  static const String meActivity = '/api/v1/users/me/activity';
  static const String meStats = '/api/v1/users/me/stats';
  static const String mePreferences = '/api/v1/users/me/preferences';
  static const String meDarkMode = '/api/v1/users/me/dark-mode';
  static const String meAvatarUploadUrl = '/api/v1/users/me/avatar/upload-url';
  static const String meAvatarConfirm = '/api/v1/users/me/avatar/confirm';
  static const String meAvatar = '/api/v1/users/me/avatar';

  // 03. Search & Discovery
  static const String search = '/api/v1/search';
  static const String searchSuggestions = '/api/v1/search/suggestions';
  static const String searchPopular = '/api/v1/search/popular';
  static const String searchRecent = '/api/v1/search/recent';
  static const String searchFacets = '/api/v1/search/facets';
  static const String searchPreviewCount = '/api/v1/search/preview-count';

  // 04. Image Search & AI Detection
  static const String imageSearchUploadUrl = '/api/v1/image-search/upload-url';
  static const String imageSearch = '/api/v1/image-search';
  static const String imageSearchRecent = '/api/v1/image-search/recent';
  static String imageSearchResult(String searchId) => '/api/v1/image-search/$searchId';
  static String imageSearchResults(String searchId) => '/api/v1/image-search/$searchId/results';
  static String imageSearchFeedback(String searchId) => '/api/v1/image-search/$searchId/feedback';

  // 05. Watch Details & Catalog
  static const String listings = '/api/v1/listings';
  static String listing(String listingId) => '/api/v1/listings/$listingId';
  static String listingPriceHistory(String listingId) => '/api/v1/listings/$listingId/price-history';
  static String listingSimilar(String listingId) => '/api/v1/listings/$listingId/similar';
  static String listingSeller(String listingId) => '/api/v1/listings/$listingId/seller';
  static String listingOutboundLink(String listingId) => '/api/v1/listings/$listingId/outbound-link';
  static const String brands = '/api/v1/brands';
  static String brand(String slug) => '/api/v1/brands/$slug';
  static String brandModels(String slug) => '/api/v1/brands/$slug/models';
  static const String watchModels = '/api/v1/watch-models';
  static String watchModel(String id) => '/api/v1/watch-models/$id';
  static String watchModelMarketSummary(String id) => '/api/v1/watch-models/$id/market-summary';
  static const String marketplaces = '/api/v1/marketplaces';

  // 06. Price Trend & Market Analytics
  static const String recommendationsHome = '/api/v1/recommendations/home';
  static const String analyticsMarketOverview = '/api/v1/analytics/market-overview';
  static const String analyticsTrending = '/api/v1/analytics/trending';
  static String analyticsPriceTrend(String watchModelId) =>
      '/api/v1/analytics/watch-models/$watchModelId/price-trend';
  static const String portfolio = '/api/v1/portfolio';
  static const String portfolioSummary = '/api/v1/portfolio/summary';

  // 07. Bookmarks & Watchlists
  static const String watchlists = '/api/v1/watchlists';
  static String watchlist(String watchlistId) => '/api/v1/watchlists/$watchlistId';
  static String watchlistItems(String watchlistId) => '/api/v1/watchlists/$watchlistId/items';
  static const String mySavedListings = '/api/v1/me/saved-listings';
  static String saveListing(String listingId) => '/api/v1/listings/$listingId/save';

  // 08. Saved Searches & Search Alerts
  static const String savedSearches = '/api/v1/saved-searches';
  static String savedSearch(String id) => '/api/v1/saved-searches/$id';
  static String savedSearchAlertsEnable(String id) => '/api/v1/saved-searches/$id/alerts/enable';
  static String savedSearchAlertsDisable(String id) => '/api/v1/saved-searches/$id/alerts/disable';

  // 09. Notifications & Price Drop Alerts
  static const String notifications = '/api/v1/notifications';
  static const String notificationsUnreadCount = '/api/v1/notifications/unread-count';
  static String notificationRead(String id) => '/api/v1/notifications/$id/read';
  static const String notificationsReadAll = '/api/v1/notifications/read-all';
  static const String notificationPreferences = '/api/v1/notification-preferences';
  static const String devices = '/api/v1/devices';

  // 10. Peer-to-Peer Marketplace & Trader Listings
  static const String myListings = '/api/v1/me/listings';
  static const String myListingsDrafts = '/api/v1/me/listings/drafts';
  static const String myListingsActive = '/api/v1/me/listings/active';
  static const String mySales = '/api/v1/me/sales';
  static const String traderCollection = '/api/v1/trader-collection';
  static const String traderCollectionFeatured = '/api/v1/trader-collection/featured';
  static String trader(String traderId) => '/api/v1/traders/$traderId';
  static String traderListings(String traderId) => '/api/v1/traders/$traderId/listings';

  // 11. In-App Orders & Transactions
  static const String orders = '/api/v1/orders';
  static String order(String orderId) => '/api/v1/orders/$orderId';
  static const String myOrders = '/api/v1/me/orders';
  static String orderPaymentIntent(String orderId) => '/api/v1/orders/$orderId/payment-intent';

  // 12. Subscriptions & Quota
  static const String subscriptionPlans = '/api/v1/subscriptions/plans';
  static const String mySubscription = '/api/v1/subscriptions/me';
  static const String mySubscriptionUsage = '/api/v1/subscriptions/me/usage';
  static const String subscriptionInvoices = '/api/v1/subscriptions/invoices';
}
