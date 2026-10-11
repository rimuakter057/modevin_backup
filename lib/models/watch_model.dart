import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';

class WatchModel {
  final int? id;
  final int? userId;
  final String title;
  final String brand;
  final String model;
  final double price;
  final String platform; // 'Chrono24', 'eBay', 'Grailzee', 'In-App'
  final int year;
  final String condition; // 'New', 'Mint', 'Very Good', 'Good', 'Fair'
  final String location;
  final bool isSold;
  final String timestamp;

  WatchModel({
    this.id,
    this.userId,
    required this.title,
    required this.brand,
    required this.model,
    required this.price,
    required this.platform,
    required this.year,
    required this.condition,
    required this.location,
    required this.isSold,
    required this.timestamp,
  });

  factory WatchModel.fromMap(Map<String, dynamic> map) {
    return WatchModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      title: map['title'] as String,
      brand: map['brand'] as String,
      model: map['model'] as String,
      price: (map['price'] as num).toDouble(),
      platform: map['platform'] as String,
      year: map['year'] as int,
      condition: map['condition'] as String,
      location: map['location'] as String,
      isSold: (map['is_sold'] as int) == 1,
      timestamp: map['timestamp'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'title': title,
      'brand': brand,
      'model': model,
      'price': price,
      'platform': platform,
      'year': year,
      'condition': condition,
      'location': location,
      'is_sold': isSold ? 1 : 0,
      'timestamp': timestamp,
    };
  }

  /// Returns a local asset path for this watch based on brand/model.
  /// Images: 1.png–8.png + rolex_watch.png in assets/images/
  String get imageUrl {
    final b = brand.toLowerCase();
    final m = model.toLowerCase();
    final t = title.toLowerCase();

    if (b.contains("rolex")) {
      if (m.contains("gmt") || t.contains("gmt")) {
        return "assets/images/1.png";
      } else if (m.contains("daytona") || t.contains("daytona")) {
        return "assets/images/2.png";
      }
      return "assets/images/rolex_watch.png";
    } else if (b.contains("omega")) {
      if (m.contains("seamaster") || t.contains("seamaster")) {
        return "assets/images/3.jpg";
      }
      return "assets/images/4.jpg";
    } else if (b.contains("patek") || b.contains("philip")) {
      return "assets/images/5.png";
    } else if (b.contains("audemars") || b.contains("ap") || b.contains("piguet")) {
      return "assets/images/6.jpg";
    } else if (b.contains("cartier")) {
      return "assets/images/7.png";
    }
    return "assets/images/8.png";
  }

  Color get platformColor {
    final bool isDark = Get.isDarkMode;
    switch (platform.toLowerCase()) {
      case 'ebay':
        return AppColors.ebay;
      case 'chrono24':
        return isDark ? const Color(0xFF60A5FA) : AppColors.chrono24;
      case 'grailzee':
        return isDark ? Colors.white : AppColors.grailzee;
      default:
        return isDark ? AppColors.accent : AppColors.primary;
    }
  }

  String get platformAbbrev {
    switch (platform.toLowerCase()) {
      case 'chrono24':
        return 'C24';
      case 'grailzee':
        return 'GZ';
      default:
        return 'eBay';
    }
  }
}
