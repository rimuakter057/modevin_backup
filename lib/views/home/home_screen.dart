import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/alert_controller.dart';
import '../../core/theme/app_colors.dart';
import 'tabs/home_tab.dart';
import 'tabs/search_tab.dart';
import 'tabs/bookmarks_tab.dart';
import 'tabs/alerts_tab.dart';
import 'tabs/profile_tab.dart';
import '../widgets/navbar/custom_navbar.dart';

class MainContainerScreen extends StatefulWidget {
  const MainContainerScreen({super.key});

  @override
  State<MainContainerScreen> createState() => _MainContainerScreenState();
}

class _MainContainerScreenState extends State<MainContainerScreen> {
  int _currentIndex = 0;
  late final List<Widget> _tabs;

  // Swipe tracking
  double _dragStartX = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _tabs = [
      HomeTab(
        onTabChangeRequested: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      SearchTab(
        onBackToHome: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
      const BookmarksTab(),
      const AlertsTab(),
      const ProfileTab(),
    ];
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
    _isDragging = true;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    // No-op: we resolve on drag end
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;

    final velocity = details.primaryVelocity ?? 0;
    // Require a meaningful swipe velocity to trigger tab change
    if (velocity < -300 && _currentIndex < _tabs.length - 1) {
      // Swiped left → next tab
      setState(() => _currentIndex++);
    } else if (velocity > 300 && _currentIndex > 0) {
      // Swiped right → previous tab
      setState(() => _currentIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: _onHorizontalDragStart,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
