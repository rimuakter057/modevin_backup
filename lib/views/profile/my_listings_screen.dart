import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controllers/search_controller.dart';
import '../../../models/watch_model.dart';
import '../../../core/theme/app_colors.dart';
import 'invoice_preview_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> with SingleTickerProviderStateMixin {
  final WatchSearchController _searchCtrl = Get.find<WatchSearchController>();
  late TabController _tabController;

  List<WatchModel> _activeListings = [];
  List<WatchModel> _soldListings = [];
  Map<int, Map<String, dynamic>> _invoices = {}; // listingId -> invoiceMap
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllListings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllListings() async {
    setState(() {
      _isLoading = true;
    });

    final active = await _searchCtrl.getUserListings(isSold: false);
    final sold = await _searchCtrl.getUserListings(isSold: true);

    // Query invoices for sold listings
    final Map<int, Map<String, dynamic>> invoiceMap = {};
    for (var watch in sold) {
      if (watch.id != null) {
        final inv = await _searchCtrl.getInvoice(watch.id!);
        if (inv != null) {
          invoiceMap[watch.id!] = inv;
        }
      }
    }

    if (mounted) {
      setState(() {
        _activeListings = active;
        _soldListings = sold;
        _invoices = invoiceMap;
        _isLoading = false;
      });
    }
  }

  void _showAddListingSheet() {
    final formKey = GlobalKey<FormState>();
    final brandCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final yearCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    String selectedCondition = 'Mint';

    final conditions = ['New', 'Mint', 'Very Good', 'Good', 'Fair'];

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: context.surfaceBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, MediaQuery.of(context).viewInsets.bottom + 24.h),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "List a Watch",
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: context.primaryNav),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Brand & Model side-by-side
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: brandCtrl,
                        style: TextStyle(color: context.textPrimaryColor),
                        decoration: InputDecoration(
                          labelText: "Brand",
                          hintText: "e.g., Rolex",
                          labelStyle: TextStyle(fontSize: 12.sp, color: context.textSecondaryColor),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty ? "Required" : null,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextFormField(
                        controller: modelCtrl,
                        style: TextStyle(color: context.textPrimaryColor),
                        decoration: InputDecoration(
                          labelText: "Model",
                          hintText: "e.g., Daytona",
                          labelStyle: TextStyle(fontSize: 12.sp, color: context.textSecondaryColor),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty ? "Required" : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Title
                TextFormField(
                  controller: titleCtrl,
                  style: TextStyle(color: context.textPrimaryColor),
                  decoration: InputDecoration(
                    labelText: "Listing Title",
                    hintText: "Rolex Daytona 116500LN Panda Dial",
                    labelStyle: TextStyle(fontSize: 12.sp, color: context.textSecondaryColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? "Required" : null,
                ),
                SizedBox(height: 12.h),

                // Price & Year side-by-side
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: priceCtrl,
                        style: TextStyle(color: context.textPrimaryColor),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Price (\$)",
                          hintText: "e.g., 29500",
                          labelStyle: TextStyle(fontSize: 12.sp, color: context.textSecondaryColor),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Required";
                          if (double.tryParse(value) == null) return "Invalid price";
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextFormField(
                        controller: yearCtrl,
                        style: TextStyle(color: context.textPrimaryColor),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Year",
                          hintText: "e.g., 2023",
                          labelStyle: TextStyle(fontSize: 12.sp, color: context.textSecondaryColor),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Required";
                          if (int.tryParse(value) == null) return "Invalid year";
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Condition & Location side-by-side
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCondition,
                        decoration: InputDecoration(
                          labelText: "Condition",
                          labelStyle: TextStyle(fontSize: 12.sp, color: context.textSecondaryColor),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        items: conditions.map((c) => DropdownMenuItem(value: c, child: Text(c, style: TextStyle(fontSize: 13.sp, color: context.textPrimaryColor)))).toList(),
                        onChanged: (val) {
                          if (val != null) selectedCondition = val;
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextFormField(
                        controller: locationCtrl,
                        style: TextStyle(color: context.textPrimaryColor),
                        decoration: InputDecoration(
                          labelText: "Location",
                          hintText: "e.g., USA",
                          labelStyle: TextStyle(fontSize: 12.sp, color: context.textSecondaryColor),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty ? "Required" : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryNav,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final success = await _searchCtrl.createCustomListing(
                          brand: brandCtrl.text.trim(),
                          model: modelCtrl.text.trim(),
                          title: titleCtrl.text.trim(),
                          price: double.parse(priceCtrl.text),
                          year: int.parse(yearCtrl.text),
                          condition: selectedCondition,
                          location: locationCtrl.text.trim(),
                        );
                        if (success) {
                          Get.back();
                          _loadAllListings();
                          Get.snackbar(
                            "Success",
                            "Your watch listing was posted successfully!",
                            backgroundColor: context.primaryNav,
                            colorText: Colors.white,
                          );
                        }
                      }
                    },
                    child: Text("Post Listing", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showGenerateInvoiceDialog(WatchModel watch) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          "Generate Billing Invoice",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: context.primaryNav),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Enter the buyer details below. Standard invoice parameters will be auto-compiled.",
                style: TextStyle(fontSize: 12.sp, color: context.textSecondaryColor),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: nameCtrl,
                style: TextStyle(color: context.textPrimaryColor),
                decoration: InputDecoration(
                  labelText: "Buyer's Name",
                  labelStyle: TextStyle(fontSize: 12.sp, color: context.textSecondaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? "Required" : null,
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: emailCtrl,
                style: TextStyle(color: context.textPrimaryColor),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Buyer's Email",
                  labelStyle: TextStyle(fontSize: 12.sp, color: context.textSecondaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Required";
                  if (!GetUtils.isEmail(value)) return "Invalid email address";
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: TextStyle(color: context.textSecondaryColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryNav,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              elevation: 0,
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final success = await _searchCtrl.generateInvoice(
                  listingId: watch.id!,
                  buyerName: nameCtrl.text.trim(),
                  buyerEmail: emailCtrl.text.trim(),
                  price: watch.price,
                );
                if (success) {
                  Get.back();
                  await _loadAllListings();
                  
                  // Instantly navigate to invoice preview
                  final inv = _invoices[watch.id!];
                  if (inv != null) {
                    Get.to(() => InvoicePreviewScreen(watch: watch, invoiceData: inv));
                  }
                }
              }
            },
            child: Text("Generate", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          "My Listings",
          style: TextStyle(color: context.primaryNav, fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.primaryNav),
          onPressed: () => Get.back(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: context.primaryNav,
          unselectedLabelColor: context.textSecondaryColor,
          indicatorColor: const Color(0xFFCA8A04),
          indicatorWeight: 3.0,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
          tabs: const [
            Tab(text: "Active Listings"),
            Tab(text: "Sold Listings"),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(context.primaryNav),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildActiveTab(),
                _buildSoldTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddListingSheet,
        backgroundColor: context.primaryNav,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildActiveTab() {
    if (_activeListings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sell_outlined, size: 64.w, color: context.borderColor),
            SizedBox(height: 16.h),
            Text(
              "You don't have any active listings",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: context.textSecondaryColor),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: _showAddListingSheet,
              child: const Text("Create Your First Listing", style: TextStyle(color: Color(0xFFCA8A04), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      itemCount: _activeListings.length,
      itemBuilder: (context, index) {
        final watch = _activeListings[index];
        final formattedPrice = '\$${watch.price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        )}';

        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          color: context.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(color: context.borderColor, width: 1.5),
          ),
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                // Image
                Container(
                  width: 56.w,
                  height: 56.h,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: context.chipBg,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Image.asset(watch.imageUrl, fit: BoxFit.contain),
                ),
                SizedBox(width: 14.w),
                // Title and Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        watch.brand.toUpperCase(),
                        style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.w900, color: const Color(0xFFCA8A04)),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        watch.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "Year: ${watch.year} • ${watch.condition} • ${watch.location}",
                        style: TextStyle(fontSize: 10.sp, color: context.textSecondaryColor),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                // Price
                Text(
                  formattedPrice,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: context.primaryNav),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSoldTab() {
    if (_soldListings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64.w, color: context.borderColor),
            SizedBox(height: 16.h),
            Text(
              "No sold listings yet",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: context.textSecondaryColor),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      itemCount: _soldListings.length,
      itemBuilder: (context, index) {
        final watch = _soldListings[index];
        final invoice = _invoices[watch.id!];
        final hasInvoice = invoice != null;

        final formattedPrice = '\$${watch.price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        )}';

        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          color: context.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(color: context.borderColor, width: 1.5),
          ),
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              children: [
                Row(
                  children: [
                    // Image
                    Container(
                      width: 56.w,
                      height: 56.h,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: context.chipBg,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Image.asset(watch.imageUrl, fit: BoxFit.contain),
                    ),
                    SizedBox(width: 14.w),
                    // Title and Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            watch.brand.toUpperCase(),
                            style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.w900, color: const Color(0xFFEF4444)),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            watch.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "Sold for: $formattedPrice",
                            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Divider(height: 1, color: context.borderColor),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (hasInvoice) ...[
                      Text(
                        "Invoice generated",
                        style: TextStyle(fontSize: 11.sp, color: const Color(0xFF10B981), fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 12.w),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryNav,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        ),
                        onPressed: () {
                          Get.to(() => InvoicePreviewScreen(watch: watch, invoiceData: invoice));
                        },
                        child: Text("View Invoice", style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold)),
                      ),
                    ] else ...[
                      Text(
                        "Billing details pending",
                        style: TextStyle(fontSize: 11.sp, color: const Color(0xFFEF4444), fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 12.w),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCA8A04),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        ),
                        onPressed: () => _showGenerateInvoiceDialog(watch),
                        child: Text("Generate Invoice", style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
