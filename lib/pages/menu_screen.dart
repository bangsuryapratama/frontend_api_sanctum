import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_api/pages/barangkeluar/list_barangkeluar.dart';
import 'package:flutter_api/pages/barangmasuk/list_barangmasuk.dart';
import 'package:flutter_api/pages/datapusat/list_data_pusat.dart';
import 'package:flutter_api/pages/home_screen.dart';
import 'package:flutter_api/pages/posts/list_posts_screen.dart';
import 'package:flutter_api/pages/profile_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  
  // Pages with proper error handling
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    
    // Initialize pages with error boundaries
    _pages = [
      _buildPageWrapper(const HomeScreen(), 'Home'),
      _buildPageWrapper(ListDataPusatPage(), 'Data Pusat'),
      _buildPageWrapper( ListBarangMasuksPage(), 'Barang Masuk'),
      _buildPageWrapper( ListBarangKeluarsPage(), 'Barang Keluar'),
      _buildPageWrapper(const ProfileScreen(), 'Profile'),
    ];

    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Wrapper untuk error handling
  Widget _buildPageWrapper(Widget page, String pageName) {
    return Builder(
      builder: (context) {
        try {
          return page;
        } catch (e) {
          return _buildErrorPage(pageName, e.toString());
        }
      },
    );
  }

  Widget _buildErrorPage(String pageName, String error) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading $pageName',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Trigger rebuild
                });
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex && index >= 0 && index < _pages.length) {
      // Haptic feedback
      HapticFeedback.lightImpact();

      setState(() {
        _currentIndex = index;
      });

      // Smooth page transition
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      
      // Simple body without any complex layout
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          if (index >= 0 && index < _pages.length) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        physics: const BouncingScrollPhysics(),
        children: _pages,
      ),
      
      // Simple standard BottomNavigationBar - guaranteed no overlap
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF6366F1),
        unselectedItemColor: Colors.grey.shade600,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.storage_outlined),
        activeIcon: Icon(Icons.storage_rounded),
        label: 'Data Pusat',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.login_outlined),
        activeIcon: Icon(Icons.login_rounded),
        label: 'Barang Masuk',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.logout_outlined),
        activeIcon: Icon(Icons.logout_rounded),
        label: 'Barang Keluar',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline_rounded),
        activeIcon: Icon(Icons.person_rounded),
        label: 'Profile',
      ),
    ]

      ),
    );
  }
}