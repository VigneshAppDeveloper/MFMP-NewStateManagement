import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_food_my_price/pages/Map/map_page.dart';
import 'package:my_food_my_price/pages/flash_sale_page.dart';
import 'package:my_food_my_price/pages/home_page.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/widgets/dilogue/dilogue.dart';

class AppPages extends StatefulWidget {
  final int initialTab; // 👈 add this
  const AppPages({super.key, this.initialTab = 0});

  @override
  State<AppPages> createState() => _AppPagesState();
}

class _AppPagesState extends State<AppPages> {
  late int _currentIndex; // 👈 make late

  DateTime? lastBackPressTime;

  final List<Widget> _pages = const [
    HomePage(),
    MapPage(),
    FlashSalePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab; // 👈 read initialTab
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // block default pop
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (_currentIndex != 0) {
          // 👈 If not on HomePage, go back to HomePage
          setState(() => _currentIndex = 0);
        } else {
          // 👈 Double back to exit
          final now = DateTime.now();
          if (lastBackPressTime == null ||
              now.difference(lastBackPressTime!) > const Duration(seconds: 2)) {
            lastBackPressTime = now;
            AppDialogue.toast("Press back again to exit");
          } else {
            SystemNavigator.pop(); // exit app
          }
        }
      },
      child: Scaffold(
        body: IndexedStack( // 👈 keeps state alive
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(51),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildNavItem(
                  assetPath: "assets/figmaIcons/homebottom.png",
                  label: 'Home',
                  index: 0,
                ),
                const SizedBox(width: 130),
                _buildNavItem(
                  assetPath: "assets/figmaIcons/offerbottom.png",
                  label: 'Flash Sale',
                  index: 2,
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: GestureDetector(
          onTap: () {
            setState(() {
              _currentIndex = _currentIndex == 1 ? 0 : 1;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _currentIndex == 1 ? Icons.list_alt : Icons.map,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  _currentIndex == 1 ? 'List View' : 'Map View',
                  style: Styles.textSmall(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textScaler: const TextScaler.linear(1.0),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildNavItem({
    IconData? icon,
    String? assetPath,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (assetPath != null)
                Image.asset(
                  assetPath,
                  height: 24,
                  width: 24,
                  color: Colors.black,
                )
              else if (icon != null)
                Icon(icon, color: Colors.black, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColor.maincolor : Colors.black,
                  fontSize: 12,
                ),
                textScaler: const TextScaler.linear(1.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
